import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/utils.dart';
import '../models/account.dart';
import '../models/app_data.dart';
import '../models/client.dart';
import '../models/lead.dart';
import '../models/movement.dart';
import '../models/project.dart';
import '../models/task_item.dart';
import 'demo_data.dart';
import 'storage_service.dart';

/// Cuenta por cobrar de un proyecto.
class Receivable {
  final Project project;
  final double totalCop;
  final double paidCop;
  final int overdueDays;
  Receivable(this.project, this.totalCop, this.paidCop, this.overdueDays);
  double get pendingCop => totalCop - paidCop;
  int get pct => totalCop == 0 ? 0 : (paidCop / totalCop * 100).round().clamp(0, 100);
}

class MonthPoint {
  final String label;
  final double income;
  final double expense;
  MonthPoint(this.label, this.income, this.expense);
}

/// Estado global + reglas de negocio. Las pantallas solo llaman a estos métodos.
class AppState extends ChangeNotifier {
  AppState({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  AppData data = AppData();
  bool ready = false;

  Future<void> load() async {
    data = await _storage.read() ?? AppData();
    ready = true;
    notifyListeners();
  }

  Future<void> _commit() async {
    notifyListeners();
    await _storage.write(data);
  }

  void _put<T>(List<T> list, T item, String Function(T) idOf) {
    final i = list.indexWhere((e) => idOf(e) == idOf(item));
    if (i < 0) {
      list.add(item);
    } else {
      list[i] = item;
    }
  }

  // ---------------- Clientes ----------------
  Future<void> saveClient(Client c) async {
    final prev = data.clients.where((e) => e.id == c.id).toList();
    // Si cambió el nombre, se actualizan proyectos y tareas que lo referencian.
    if (prev.isNotEmpty && prev.first.name != c.name) {
      final old = prev.first.name;
      for (final p in data.projects.where((p) => p.client == old)) {
        p.client = c.name;
      }
      for (final t in data.tasks.where((t) => t.client == old)) {
        t.client = c.name;
      }
    }
    _put(data.clients, c, (e) => e.id);
    await _commit();
  }

  Future<void> deleteClient(String id) async {
    data.clients.removeWhere((e) => e.id == id);
    await _commit();
  }

  List<Project> projectsOfClient(String name) =>
      data.projects.where((p) => p.client == name).toList();

  // ---------------- Proyectos ----------------
  Future<void> saveProject(Project p) async {
    _put(data.projects, p, (e) => e.id);
    await _commit();
  }

  Future<void> moveProject(String id, String stage) async {
    final p = data.projects.firstWhere((e) => e.id == id);
    p.stage = stage;
    await _commit();
  }

  /// Elimina el proyecto y los movimientos que se generaron por sus pagos.
  Future<void> deleteProject(String id) async {
    data.projects.removeWhere((e) => e.id == id);
    data.income.removeWhere((e) => e.projectId == id);
    data.expenses.removeWhere((e) => e.projectId == id);
    await _commit();
  }

  Project? projectById(String id) {
    for (final p in data.projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> addPayment(String projectId, double amount, String cur, String account, String date) async {
    final p = projectById(projectId);
    if (p == null) return;
    final incId = newId();
    data.income.add(Movement(
        id: incId, concept: 'Pago · ${p.title}', amount: amount, cur: cur,
        account: account, date: date, projectId: projectId));
    p.payments.add(Payment(
        id: newId(), amount: amount, cur: cur, account: account, date: date, incomeId: incId));
    await _commit();
  }

  Future<void> undoPayment(String projectId, String paymentId) async {
    final p = projectById(projectId);
    if (p == null) return;
    final pay = p.payments.where((x) => x.id == paymentId).toList();
    if (pay.isEmpty) return;
    data.income.removeWhere((i) => i.id == pay.first.incomeId);
    if (pay.first.feeExpenseId != null) {
      data.expenses.removeWhere((e) => e.id == pay.first.feeExpenseId);
    }
    p.payments.removeWhere((x) => x.id == paymentId);
    await _commit();
  }

  // ---------------- Pipeline ----------------
  Future<void> saveLead(Lead l) async {
    _put(data.leads, l, (e) => e.id);
    await _commit();
  }

  Future<void> moveLead(String id, String stage, {String lostReason = ''}) async {
    final l = data.leads.firstWhere((e) => e.id == id);
    l.stage = stage;
    l.lostReason = stage == 'lost' ? lostReason : '';
    await _commit();
  }

  Future<void> deleteLead(String id) async {
    data.leads.removeWhere((e) => e.id == id);
    await _commit();
  }

  bool clientExists(String name) =>
      data.clients.any((c) => c.name.toLowerCase() == name.toLowerCase());

  /// Crea un cliente copiando los datos del prospecto ganado.
  Future<void> convertLeadToClient(String leadId) async {
    final l = data.leads.firstWhere((e) => e.id == leadId);
    if (clientExists(l.name)) return;
    final sym = l.cur == 'COP' ? r'$' : l.cur == 'USD' ? r'US$' : '€';
    final amount = l.cur == 'COP' ? fmtInt(l.value) : l.value.toStringAsFixed(2);
    data.clients.add(Client(
      id: newId(),
      name: l.name,
      contact: l.contact,
      type: l.service.isEmpty ? 'Otro' : l.service,
      status: 'active',
      rate: l.value > 0 ? '$sym$amount ${l.cur}' : '',
      notes: l.notes.isNotEmpty
          ? 'Del pipeline: ${l.notes}'
          : 'Convertido desde el pipeline de ventas.',
    ));
    await _commit();
  }

  // ---------------- Tareas ----------------
  Future<void> saveTask(TaskItem t) async {
    _put(data.tasks, t, (e) => e.id);
    await _commit();
  }

  Future<void> toggleTask(String id) async {
    final t = data.tasks.firstWhere((e) => e.id == id);
    t.done = !t.done;
    await _commit();
  }

  Future<void> deleteTask(String id) async {
    data.tasks.removeWhere((e) => e.id == id);
    await _commit();
  }

  Future<void> clearDoneTasks() async {
    data.tasks.removeWhere((e) => e.done);
    await _commit();
  }

  // ---------------- Finanzas ----------------
  Future<void> saveMovement(bool isIncome, Movement m) async {
    _put(isIncome ? data.income : data.expenses, m, (e) => e.id);
    // Si el ingreso viene de un pago de proyecto, el pago se mantiene sincronizado.
    if (isIncome && m.projectId != null) {
      final p = projectById(m.projectId!);
      if (p != null) {
        for (final pay in p.payments.where((x) => x.incomeId == m.id)) {
          pay.amount = m.amount;
          pay.cur = m.cur;
          pay.account = m.account;
          pay.date = m.date;
        }
      }
    }
    await _commit();
  }

  Future<void> deleteMovement(bool isIncome, String id) async {
    if (isIncome) {
      final m = data.income.where((e) => e.id == id).toList();
      if (m.isNotEmpty && m.first.projectId != null) {
        final p = projectById(m.first.projectId!);
        p?.payments.removeWhere((x) => x.incomeId == id);
      }
      data.income.removeWhere((e) => e.id == id);
    } else {
      data.expenses.removeWhere((e) => e.id == id);
    }
    await _commit();
  }

  double fxOf(String cur) => data.fx[cur] ?? 1;

  double toCop(double amount, String cur) => amount * fxOf(cur);

  Account? account(String id) {
    for (final a in data.accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  String accountName(String id) => account(id)?.name ?? 'Cuenta eliminada';

  double projectPaidCop(Project p) =>
      p.payments.fold(0.0, (s, pay) => s + toCop(pay.amount, pay.cur));

  /// Lo que falta por cobrar, expresado en la moneda del proyecto.
  double projectPendingNative(Project p) {
    final pending = toCop(p.price, p.cur) - projectPaidCop(p);
    if (pending <= 0) return 0;
    return pending / fxOf(p.cur);
  }

  List<Receivable> receivables() {
    final list = <Receivable>[];
    for (final p in data.projects.where((p) => p.price > 0)) {
      final total = toCop(p.price, p.cur);
      final paid = projectPaidCop(p);
      if (total - paid <= 0) continue;
      final dl = daysLeft(p.due);
      list.add(Receivable(p, total, paid, dl == null ? 0 : (dl < 0 ? -dl : 0)));
    }
    list.sort((a, b) {
      final byOverdue = b.overdueDays.compareTo(a.overdueDays);
      return byOverdue != 0 ? byOverdue : b.pendingCop.compareTo(a.pendingCop);
    });
    return list;
  }

  double get receivableTotalCop => receivables().fold(0.0, (s, r) => s + r.pendingCop);

  /// Saldo de cada cuenta en su propia moneda (incluye transferencias importadas).
  Map<String, double> balances() {
    final b = <String, double>{for (final a in data.accounts) a.id: 0.0};
    double inAccount(String accId, double amount, String cur) {
      final a = account(accId);
      return toCop(amount, cur) / fxOf(a?.cur ?? 'COP');
    }

    for (final i in data.income) {
      if (b.containsKey(i.account)) b[i.account] = b[i.account]! + inAccount(i.account, i.amount, i.cur);
    }
    for (final e in data.expenses) {
      if (b.containsKey(e.account)) b[e.account] = b[e.account]! - inAccount(e.account, e.amount, e.cur);
    }
    for (final raw in data.transfers) {
      if (raw is! Map) continue;
      final from = asStr(raw['from']);
      final to = asStr(raw['to']);
      final amount = asNum(raw['amount']);
      final fromCur = asStr(raw['fromCur'], 'COP');
      if (b.containsKey(from)) {
        var out = inAccount(from, amount, fromCur);
        final fee = asNum(raw['feeAmount']);
        if (fee > 0) out += inAccount(from, fee, asStr(raw['feeCur'], fromCur));
        b[from] = b[from]! - out;
      }
      if (b.containsKey(to)) {
        final received = raw['toAmount'] != null ? asNum(raw['toAmount']) : amount;
        final rcur = asStr(raw['toCur'], fromCur);
        b[to] = b[to]! + inAccount(to, received, rcur);
      }
    }
    return b;
  }

  double get totalBalanceCop {
    final b = balances();
    return data.accounts.fold(0.0, (s, a) => s + (b[a.id] ?? 0) * fxOf(a.cur));
  }

  /// Ingresos y gastos (en COP) de los últimos [n] meses, el más reciente al final.
  List<MonthPoint> monthlySeries(int n) {
    final now = DateTime.now();
    final points = <MonthPoint>[];
    for (var k = n - 1; k >= 0; k--) {
      final m = DateTime(now.year, now.month - k, 1);
      final prefix = '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
      double sum(List<Movement> l) => l
          .where((e) => e.date.startsWith(prefix))
          .fold(0.0, (s, e) => s + toCop(e.amount, e.cur));
      points.add(MonthPoint(monthNames[m.month - 1].substring(0, 3), sum(data.income), sum(data.expenses)));
    }
    return points;
  }

  double get incomeThisMonthCop => monthlySeries(1).last.income;
  double get expensesThisMonthCop => monthlySeries(1).last.expense;

  // ---------------- Ajustes ----------------
  Future<void> setFx(double usd, double eur) async {
    if (usd > 0) data.fx['USD'] = usd;
    if (eur > 0) data.fx['EUR'] = eur;
    data.fx['COP'] = 1;
    await _commit();
  }

  Future<void> setEditors(List<String> editors) async {
    data.editors = editors.where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList();
    await _commit();
  }

  Future<void> setCapacity(int n) async {
    data.capacity = n < 1 ? 1 : n;
    await _commit();
  }

  Future<void> clearAll() async {
    data = AppData();
    await _commit();
  }

  Future<void> loadDemo() async {
    data = buildDemoData();
    await _commit();
  }

  // ---------------- Respaldo ----------------
  String exportJson() => const JsonEncoder.withIndent('  ').convert(data.toJson());

  /// Reemplaza los datos con un JSON exportado (de esta app o de la versión web).
  /// Lanza [FormatException] si el texto no es válido.
  Future<void> importJson(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('El JSON debe ser un objeto');
    final map = Map<String, dynamic>.from(decoded);
    if (!map.containsKey('clients') && !map.containsKey('projects') && !map.containsKey('settings')) {
      throw const FormatException('No parece un respaldo de Sebasgova Edición');
    }
    data = AppData.fromJson(map);
    await _commit();
  }
}
