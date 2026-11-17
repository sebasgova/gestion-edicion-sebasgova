import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sebasgova_edicion/core/utils.dart';
import 'package:sebasgova_edicion/models/app_data.dart';
import 'package:sebasgova_edicion/models/client.dart';
import 'package:sebasgova_edicion/models/lead.dart';
import 'package:sebasgova_edicion/models/movement.dart';
import 'package:sebasgova_edicion/models/project.dart';
import 'package:sebasgova_edicion/services/app_state.dart';

Future<AppState> freshState() async {
  SharedPreferences.setMockInitialValues({});
  final s = AppState();
  await s.load();
  return s;
}

void main() {
  group('utils', () {
    test('parseMoney entiende COP y monedas con decimales', () {
      expect(parseMoney('1.234.567', 'COP'), 1234567);
      expect(parseMoney(r'$ 350.000', 'COP'), 350000);
      expect(parseMoney('1,234.50', 'USD'), 1234.5);
      expect(parseMoney('99,5', 'EUR'), 99.5);
      expect(parseMoney('', 'USD'), 0);
    });

    test('fmtCop agrupa miles con punto', () {
      expect(fmtCop(1234567), r'$1.234.567');
      expect(fmtCop(0), r'$0');
    });

    test('daysLeft: hoy es 0 y ayer es -1', () {
      expect(daysLeft(todayIso()), 0);
      expect(daysLeft(plusDaysIso(-1)), -1);
      expect(daysLeft(''), isNull);
    });
  });

  group('AppData JSON', () {
    test('ida y vuelta conserva campos desconocidos de la web', () {
      final web = {
        'clients': [
          {'id': 'a', 'name': 'Cliente A', 'status': 'active'}
        ],
        'projects': [
          {
            'id': 'p',
            'title': 'Proyecto',
            'client': 'Cliente A',
            'price': 100,
            'cur': 'USD',
            'monthly': true,
            'videos': [
              {'id': 'v1', 'title': 'Video 1'}
            ],
          }
        ],
        'transfers': [
          {'id': 't', 'from': 'paypal', 'to': 'bancolombia'}
        ],
        'settings': {
          'fx': {'COP': 1, 'USD': 4000, 'EUR': 4400},
          'modules': {'finance': true},
        },
      };
      final data = AppData.fromJson(web);
      expect(data.fx['USD'], 4000);
      final out = data.toJson();
      final project = (out['projects'] as List).first as Map;
      expect(project['monthly'], true);
      expect((project['videos'] as List).length, 1);
      expect((out['transfers'] as List).length, 1);
      expect(((out['settings'] as Map)['modules'] as Map)['finance'], true);
    });
  });

  group('AppState', () {
    test('pago de proyecto crea ingreso y reduce lo pendiente; se puede revertir', () async {
      final s = await freshState();
      await s.saveProject(Project(id: 'p1', title: 'Reel', price: 1000, cur: 'USD'));
      expect(s.projectPendingNative(s.projectById('p1')!), closeTo(1000, 0.001));

      await s.addPayment('p1', 400, 'USD', 'paypal', todayIso());
      expect(s.data.income.length, 1);
      expect(s.data.income.first.projectId, 'p1');
      expect(s.projectPendingNative(s.projectById('p1')!), closeTo(600, 0.001));
      expect(s.receivables().length, 1);

      final payId = s.projectById('p1')!.payments.first.id;
      await s.undoPayment('p1', payId);
      expect(s.data.income, isEmpty);
      expect(s.projectPendingNative(s.projectById('p1')!), closeTo(1000, 0.001));
    });

    test('pagar el total saca el proyecto de cuentas por cobrar', () async {
      final s = await freshState();
      await s.saveProject(Project(id: 'p1', title: 'VSL', price: 500000, cur: 'COP'));
      await s.addPayment('p1', 500000, 'COP', 'bancolombia', todayIso());
      expect(s.receivables(), isEmpty);
    });

    test('eliminar un proyecto elimina los ingresos de sus pagos', () async {
      final s = await freshState();
      await s.saveProject(Project(id: 'p1', title: 'X', price: 10, cur: 'USD'));
      await s.addPayment('p1', 10, 'USD', 'paypal', todayIso());
      await s.deleteProject('p1');
      expect(s.data.projects, isEmpty);
      expect(s.data.income, isEmpty);
    });

    test('saldos por cuenta consideran ingresos, gastos y transferencias', () async {
      final s = await freshState();
      await s.saveMovement(true, Movement(id: 'i', concept: 'Pago', amount: 100, cur: 'USD', account: 'paypal'));
      await s.saveMovement(false, Movement(id: 'e', concept: 'Gasto', amount: 20, cur: 'USD', account: 'paypal'));
      s.data.transfers = [
        {'from': 'paypal', 'to': 'bancolombia', 'amount': 10, 'fromCur': 'USD', 'toAmount': 34370, 'toCur': 'COP'}
      ];
      final b = s.balances();
      expect(b['paypal'], closeTo(70, 0.001));
      expect(b['bancolombia'], closeTo(34370, 0.001));
    });

    test('convertir prospecto ganado crea cliente una sola vez', () async {
      final s = await freshState();
      await s.saveLead(Lead(id: 'l', name: 'Nómada', value: 150, cur: 'USD', stage: 'won', service: 'VSL'));
      await s.convertLeadToClient('l');
      await s.convertLeadToClient('l');
      expect(s.data.clients.length, 1);
      expect(s.data.clients.first.rate, 'US\$150.00 USD');
    });

    test('renombrar cliente actualiza sus proyectos', () async {
      final s = await freshState();
      await s.saveClient(Client(id: 'c', name: 'Viejo'));
      await s.saveProject(Project(id: 'p', title: 'P', client: 'Viejo'));
      await s.saveClient(Client(id: 'c', name: 'Nuevo'));
      expect(s.projectById('p')!.client, 'Nuevo');
    });

    test('exportar e importar reconstruye los mismos datos', () async {
      final s = await freshState();
      await s.loadDemo();
      final json = s.exportJson();
      final other = await freshState();
      await other.importJson(json);
      expect(other.data.projects.length, s.data.projects.length);
      expect(other.data.income.length, s.data.income.length);
      expect(other.totalBalanceCop, closeTo(s.totalBalanceCop, 0.01));
    });

    test('importar texto inválido lanza FormatException', () async {
      final s = await freshState();
      expect(() => s.importJson('[1,2,3]'), throwsFormatException);
      expect(() => s.importJson('{"otra":1}'), throwsFormatException);
    });

    test('los datos persisten entre sesiones', () async {
      SharedPreferences.setMockInitialValues({});
      final a = AppState();
      await a.load();
      await a.saveClient(Client(id: 'c', name: 'Persistente'));
      final b = AppState();
      await b.load();
      expect(b.data.clients.single.name, 'Persistente');
    });
  });
}
