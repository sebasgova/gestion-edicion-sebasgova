import '../core/constants.dart';
import '../core/utils.dart';
import 'account.dart';
import 'client.dart';
import 'lead.dart';
import 'movement.dart';
import 'project.dart';
import 'task_item.dart';

/// Todo lo que se guarda. El JSON usa las mismas claves que la versión web
/// (`clients, projects, leads, tasks, income, expenses, transfers, settings`),
/// así se puede exportar en el HTML y cargar aquí (y viceversa).
class AppData {
  List<Client> clients;
  List<Project> projects;
  List<Lead> leads;
  List<TaskItem> tasks;
  List<Movement> income;
  List<Movement> expenses;
  List<Account> accounts;
  Map<String, double> fx;
  List<String> editors;
  int capacity;

  /// Datos que la app Flutter aún no edita; se preservan.
  List<dynamic> transfers;
  Map<String, dynamic> settingsExtra;

  AppData({
    List<Client>? clients,
    List<Project>? projects,
    List<Lead>? leads,
    List<TaskItem>? tasks,
    List<Movement>? income,
    List<Movement>? expenses,
    List<Account>? accounts,
    Map<String, double>? fx,
    List<String>? editors,
    this.capacity = 5,
    List<dynamic>? transfers,
    Map<String, dynamic>? settingsExtra,
  })  : clients = clients ?? [],
        projects = projects ?? [],
        leads = leads ?? [],
        tasks = tasks ?? [],
        income = income ?? [],
        expenses = expenses ?? [],
        accounts = accounts ?? defaultAccounts(),
        fx = fx ?? Map<String, double>.from(AppConst.defaultFx),
        editors = editors ?? List<String>.from(AppConst.defaultEditors),
        transfers = transfers ?? [],
        settingsExtra = settingsExtra ?? {};

  static List<Account> defaultAccounts() => [
        Account(id: 'bancolombia', name: 'Bancolombia', cur: 'COP', color: 0xFFF5D020),
        Account(id: 'paypal', name: 'PayPal', cur: 'USD', color: 0xFF3B7BBF),
        Account(id: 'payoneer', name: 'Payoneer', cur: 'USD', color: 0xFFD2654F),
        Account(id: 'arq', name: 'ARQ', cur: 'USD', color: 0xFF4EA674),
      ];

  factory AppData.fromJson(Map<String, dynamic> j) {
    final settings = j['settings'] is Map
        ? Map<String, dynamic>.from(j['settings'] as Map)
        : <String, dynamic>{};
    final fx = Map<String, double>.from(AppConst.defaultFx);
    if (settings['fx'] is Map) {
      (settings['fx'] as Map).forEach((k, v) {
        final n = asNum(v);
        if (n > 0) fx['$k'] = n;
      });
    }
    fx['COP'] = 1;
    final accs = asMapList(settings['accounts']).map(Account.fromJson).toList();
    final eds = settings['editors'] is List
        ? (settings['editors'] as List).map((e) => '$e').toList()
        : List<String>.from(AppConst.defaultEditors);
    final extra = Map<String, dynamic>.from(settings)
      ..removeWhere((k, _) => const {'fx', 'accounts', 'editors', 'capacity'}.contains(k));
    return AppData(
      clients: asMapList(j['clients']).map(Client.fromJson).toList(),
      projects: asMapList(j['projects']).map(Project.fromJson).toList(),
      leads: asMapList(j['leads']).map(Lead.fromJson).toList(),
      tasks: asMapList(j['tasks']).map(TaskItem.fromJson).toList(),
      income: asMapList(j['income']).map(Movement.fromJson).toList(),
      expenses: asMapList(j['expenses']).map(Movement.fromJson).toList(),
      accounts: accs.isEmpty ? defaultAccounts() : accs,
      fx: fx,
      editors: eds,
      capacity: asInt(settings['capacity'], 5),
      transfers: j['transfers'] is List ? List<dynamic>.from(j['transfers'] as List) : [],
      settingsExtra: extra,
    );
  }

  Map<String, dynamic> toJson() => {
        'clients': clients.map((e) => e.toJson()).toList(),
        'projects': projects.map((e) => e.toJson()).toList(),
        'leads': leads.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'income': income.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'transfers': transfers,
        'settings': {
          ...settingsExtra,
          'capacity': capacity,
          'fx': fx,
          'editors': editors,
          'accounts': accounts.map((e) => e.toJson()).toList(),
        },
      };
}
