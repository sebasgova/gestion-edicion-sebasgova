import '../core/utils.dart';
import '../models/app_data.dart';
import '../models/client.dart';
import '../models/lead.dart';
import '../models/movement.dart';
import '../models/project.dart';
import '../models/task_item.dart';

/// Datos de ejemplo para probar y sustentar la app sin escribir todo a mano.
AppData buildDemoData() {
  final d = AppData();
  d.clients = [
    Client(id: 'c1', name: 'Lumen Studio', contact: '@lumenstudio', type: 'Reel (Paquete mensual)',
        rate: '€350/video', status: 'active', notes: 'Prefiere entregas los viernes.'),
    Client(id: 'c2', name: 'Valeria Fitness', contact: 'valeria@email.com', type: 'YouTube (Individual)',
        rate: 'US\$280/video', status: 'active'),
    Client(id: 'c3', name: 'Andes Coffee', contact: '@andescoffee', type: 'VSL',
        rate: r'$1.800.000 COP', status: 'paused'),
  ];

  final p1 = Project(id: 'p1', client: 'Lumen Studio', title: 'Reels noviembre (x8)',
      service: 'Reel (Paquete mensual)', stage: 'edit', due: plusDaysIso(4),
      price: 1200, cur: 'EUR', revUsed: 1, revMax: 3, editor: 'Yo');
  final p2 = Project(id: 'p2', client: 'Valeria Fitness', title: 'Rutina full body (YouTube)',
      service: 'YouTube (Individual)', stage: 'review', due: plusDaysIso(1),
      price: 280, cur: 'USD', revUsed: 2, revMax: 2, editor: 'Editor externo');
  final p3 = Project(id: 'p3', client: 'Andes Coffee', title: 'VSL lanzamiento café',
      service: 'VSL', stage: 'todo', due: plusDaysIso(-2),
      price: 1800000, cur: 'COP', editor: 'Yo');
  final p4 = Project(id: 'p4', client: 'Lumen Studio', title: 'Reels octubre (x8)',
      service: 'Reel (Paquete mensual)', stage: 'delivered', due: plusDaysIso(-20),
      price: 1200, cur: 'EUR', revUsed: 2, revMax: 3, editor: 'Yo');
  d.projects = [p1, p2, p3, p4];

  void pay(Project p, double amount, String account, int daysAgo) {
    final incId = newId();
    d.income.add(Movement(id: incId, concept: 'Pago · ${p.title}', amount: amount, cur: p.cur,
        account: account, date: plusDaysIso(-daysAgo), projectId: p.id));
    p.payments.add(Payment(id: newId(), amount: amount, cur: p.cur, account: account,
        date: plusDaysIso(-daysAgo), incomeId: incId));
  }

  pay(p4, 1200, 'paypal', 15);
  pay(p1, 600, 'paypal', 6);
  pay(p2, 140, 'payoneer', 3);

  d.income.add(Movement(id: newId(), concept: 'Proyecto freelance Fiverr', amount: 95, cur: 'USD',
      account: 'payoneer', date: plusDaysIso(-40)));
  d.income.add(Movement(id: newId(), concept: 'Edición boda (cliente local)', amount: 900000, cur: 'COP',
      account: 'bancolombia', date: plusDaysIso(-70)));
  d.expenses = [
    Movement(id: newId(), concept: 'Suscripción Adobe', amount: 22, cur: 'USD', account: 'paypal',
        date: plusDaysIso(-10)),
    Movement(id: newId(), concept: 'Pago editor externo', amount: 350000, cur: 'COP',
        account: 'bancolombia', date: plusDaysIso(-8)),
    Movement(id: newId(), concept: 'Internet', amount: 120000, cur: 'COP', account: 'bancolombia',
        date: plusDaysIso(-35)),
  ];

  d.leads = [
    Lead(id: 'l1', name: 'Nómada Travel', source: 'Instagram', service: 'Reel (Individual)',
        value: 150, cur: 'USD', stage: 'qualify', contact: '@nomadatravel'),
    Lead(id: 'l2', name: 'Dr. Ramírez', source: 'Referidos', service: 'YouTube (Paquete mensual)',
        value: 900, cur: 'USD', stage: 'discovery', notes: 'Llamada el jueves.'),
    Lead(id: 'l3', name: 'Kombucha Lab', source: 'ADS', service: 'Reel (Paquete mensual)',
        value: 700, cur: 'USD', stage: 'pricing'),
    Lead(id: 'l4', name: 'Lumen Studio', source: 'LinkedIn', service: 'Reel (Paquete mensual)',
        value: 1200, cur: 'EUR', stage: 'won'),
    Lead(id: 'l5', name: 'Gym Titan', source: 'Fiverr', service: 'Reel (Individual)',
        value: 80, cur: 'USD', stage: 'lost', lostReason: 'Pricing'),
  ];

  d.tasks = [
    TaskItem(id: 't1', text: 'Enviar cotización a Kombucha Lab', client: '', prio: 'alta', due: plusDaysIso(1)),
    TaskItem(id: 't2', text: 'Subir cambios de Valeria a Drive', client: 'Valeria Fitness', prio: 'media',
        due: plusDaysIso(2)),
    TaskItem(id: 't3', text: 'Renovar licencia de música', prio: 'baja', due: plusDaysIso(12)),
    TaskItem(id: 't4', text: 'Facturar proyecto de octubre', client: 'Lumen Studio', prio: 'media', done: true),
  ];
  return d;
}
