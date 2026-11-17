import '../core/utils.dart';

/// Pago recibido por un proyecto (genera un ingreso enlazado).
class Payment {
  final String id;
  double amount;
  String cur;
  String account;
  String date;
  String incomeId;
  String? feeExpenseId;

  Payment({
    required this.id,
    required this.amount,
    required this.cur,
    required this.account,
    required this.date,
    required this.incomeId,
    this.feeExpenseId,
  });

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: asStr(j['id'], newId()),
        amount: asNum(j['amount']),
        cur: asStr(j['cur'], 'COP'),
        account: asStr(j['account']),
        date: asStr(j['date']),
        incomeId: asStr(j['incomeId']),
        feeExpenseId: j['feeExpenseId'] == null ? null : asStr(j['feeExpenseId']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'cur': cur,
        'account': account,
        'date': date,
        'incomeId': incomeId,
        if (feeExpenseId != null) 'feeExpenseId': feeExpenseId,
      };
}

class Project {
  static const _known = {
    'id', 'client', 'title', 'service', 'stage', 'due', 'price', 'cur',
    'revUsed', 'revMax', 'editor', 'drive', 'payments',
  };

  final String id;
  String client; // nombre del cliente (igual que en la web)
  String title;
  String service;
  String stage; // id de etapa de trabajo
  String due;
  double price;
  String cur;
  int revUsed;
  int revMax;
  String editor;
  String drive;
  List<Payment> payments;

  /// Campos de la web que esta versión aún no usa (videos, lotes...).
  /// Se conservan para no perderlos al guardar o exportar.
  Map<String, dynamic> extra;

  Project({
    required this.id,
    required this.title,
    this.client = '',
    this.service = 'Reel (Individual)',
    this.stage = 'todo',
    this.due = '',
    this.price = 0,
    this.cur = 'COP',
    this.revUsed = 0,
    this.revMax = 2,
    this.editor = '',
    this.drive = '',
    List<Payment>? payments,
    Map<String, dynamic>? extra,
  })  : payments = payments ?? [],
        extra = extra ?? {};

  factory Project.fromJson(Map<String, dynamic> j) {
    final extra = Map<String, dynamic>.from(j)
      ..removeWhere((k, _) => _known.contains(k));
    return Project(
      id: asStr(j['id'], newId()),
      client: asStr(j['client']),
      title: asStr(j['title']),
      service: asStr(j['service']),
      stage: asStr(j['stage'], 'todo'),
      due: asStr(j['due']),
      price: asNum(j['price']),
      cur: asStr(j['cur'], 'COP'),
      revUsed: asInt(j['revUsed']),
      revMax: asInt(j['revMax'], 2),
      editor: asStr(j['editor']),
      drive: asStr(j['drive']),
      payments: asMapList(j['payments']).map(Payment.fromJson).toList(),
      extra: extra,
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        'id': id,
        'client': client,
        'title': title,
        'service': service,
        'stage': stage,
        'due': due,
        'price': price,
        'cur': cur,
        'revUsed': revUsed,
        'revMax': revMax,
        'editor': editor,
        'drive': drive,
        'payments': payments.map((p) => p.toJson()).toList(),
      };
}
