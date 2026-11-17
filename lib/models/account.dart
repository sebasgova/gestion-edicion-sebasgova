import '../core/utils.dart';

class Account {
  final String id;
  String name;
  String cur;
  int color; // ARGB
  Map<String, dynamic>? fee; // se conserva tal cual para no perder datos de la web

  Account({
    required this.id,
    required this.name,
    this.cur = 'COP',
    this.color = 0xFF6D8BFF,
    this.fee,
  });

  static int _parseColor(dynamic v) {
    final s = asStr(v).replaceAll('#', '');
    if (s.length == 6) return int.tryParse('FF$s', radix: 16) ?? 0xFF6D8BFF;
    return 0xFF6D8BFF;
  }

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        id: asStr(j['id'], newId()),
        name: asStr(j['name']),
        cur: asStr(j['cur'], 'COP'),
        color: _parseColor(j['color']),
        fee: j['fee'] is Map ? Map<String, dynamic>.from(j['fee'] as Map) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cur': cur,
        'color': '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        if (fee != null) 'fee': fee,
      };
}
