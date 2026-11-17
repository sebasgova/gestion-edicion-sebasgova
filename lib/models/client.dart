import '../core/utils.dart';

class Client {
  final String id;
  String name;
  String contact;
  String type; // servicio principal
  String rate;
  String status; // active | lead | paused | done
  String drive;
  String notes;

  Client({
    required this.id,
    required this.name,
    this.contact = '',
    this.type = 'Reel (Individual)',
    this.rate = '',
    this.status = 'active',
    this.drive = '',
    this.notes = '',
  });

  factory Client.fromJson(Map<String, dynamic> j) => Client(
        id: asStr(j['id'], newId()),
        name: asStr(j['name']),
        contact: asStr(j['contact']),
        type: asStr(j['type'], 'Otro'),
        rate: asStr(j['rate']),
        status: asStr(j['status'], 'active'),
        drive: asStr(j['drive']),
        notes: asStr(j['notes']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'type': type,
        'rate': rate,
        'status': status,
        'drive': drive,
        'notes': notes,
      };
}
