/// Utilidades de formato, fechas, ids y conversión JSON.
library;

int _idCounter = 0;

/// Id corto y único para registros nuevos.
String newId() {
  _idCounter++;
  return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${_idCounter.toRadixString(36)}';
}

// ---------- JSON tolerante ----------
String asStr(dynamic v, [String fallback = '']) => v == null ? fallback : '$v';

double asNum(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

int asInt(dynamic v, [int fallback = 0]) => asNum(v, fallback.toDouble()).round();

bool asBool(dynamic v, [bool fallback = false]) => v is bool ? v : fallback;

List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return [];
  return v
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

// ---------- Dinero ----------
String fmtInt(num n) {
  final neg = n < 0;
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}$b';
}

String fmtCop(num n) => '\$${fmtInt(n)}';

/// Monto en su moneda nativa, p. ej. `US$120.50`.
String fmtNative(num n, String cur) {
  switch (cur) {
    case 'COP':
      return '\$${fmtInt(n)} COP';
    case 'USD':
      return 'US\$${n.toStringAsFixed(2)}';
    case 'EUR':
      return '€${n.toStringAsFixed(2)}';
    default:
      return '${n.toStringAsFixed(2)} $cur';
  }
}

String fmtCompact(num n) {
  final a = n.abs();
  final sign = n < 0 ? '-' : '';
  if (a >= 1000000) return '$sign\$${(a / 1000000).toStringAsFixed(1)}M';
  if (a >= 1000) return '$sign\$${(a / 1000).toStringAsFixed(0)}k';
  return '$sign\$${a.toStringAsFixed(0)}';
}

/// Convierte texto escrito por el usuario a número. En COP no hay decimales.
double parseMoney(String raw, String cur) {
  final s = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (s.isEmpty) return 0;
  if (cur == 'COP') return double.tryParse(s.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
  final lastDot = s.lastIndexOf('.');
  final lastComma = s.lastIndexOf(',');
  final pos = lastDot > lastComma ? lastDot : lastComma;
  if (pos < 0) return double.tryParse(s) ?? 0;
  final intPart = s.substring(0, pos).replaceAll(RegExp(r'[.,]'), '');
  return double.tryParse('$intPart.${s.substring(pos + 1)}') ?? 0;
}

/// Texto editable de un monto (sin símbolo).
String moneyToField(double n, String cur) {
  if (n == 0) return '';
  return cur == 'COP' ? n.round().toString() : n.toStringAsFixed(2);
}

// ---------- Fechas (ISO yyyy-MM-dd) ----------
const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];
const monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String isoOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String todayIso() => isoOf(DateTime.now());

String plusDaysIso(int days) => isoOf(DateTime.now().add(Duration(days: days)));

/// Días hasta la fecha (negativo = vencida). `null` si no hay fecha válida.
int? daysLeft(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final d = DateTime.tryParse(iso);
  if (d == null) return null;
  final t = DateTime.now();
  return DateTime.utc(d.year, d.month, d.day)
      .difference(DateTime.utc(t.year, t.month, t.day))
      .inDays;
}

String fmtDay(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

String dueLabel(int? d) {
  if (d == null) return '';
  if (d < 0) return '${-d}d tarde';
  if (d == 0) return 'Hoy';
  return 'en ${d}d';
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}
