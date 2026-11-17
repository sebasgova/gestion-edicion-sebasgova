import '../core/utils.dart';

/// Prospecto del pipeline de ventas.
class Lead {
  final String id;
  String name;
  String contact;
  String source;
  String service;
  double value;
  String cur;
  String stage; // qualify | discovery | pricing | won | lost
  String notes;
  String lostReason;

  Lead({
    required this.id,
    required this.name,
    this.contact = '',
    this.source = 'Instagram',
    this.service = 'Reel (Individual)',
    this.value = 0,
    this.cur = 'USD',
    this.stage = 'qualify',
    this.notes = '',
    this.lostReason = '',
  });

  factory Lead.fromJson(Map<String, dynamic> j) => Lead(
        id: asStr(j['id'], newId()),
        name: asStr(j['name']),
        contact: asStr(j['contact']),
        source: asStr(j['source']),
        service: asStr(j['service']),
        value: asNum(j['value']),
        cur: asStr(j['cur'], 'USD'),
        stage: asStr(j['stage'], 'qualify'),
        notes: asStr(j['notes']),
        lostReason: asStr(j['lostReason']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'source': source,
        'service': service,
        'value': value,
        'cur': cur,
        'stage': stage,
        'notes': notes,
        'lostReason': lostReason,
      };
}
