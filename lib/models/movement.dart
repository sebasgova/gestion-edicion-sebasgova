import '../core/utils.dart';

/// Ingreso o gasto (la lista a la que pertenece define su tipo).
class Movement {
  final String id;
  String concept;
  double amount;
  String cur;
  String account;
  String date;
  String? projectId;
  bool fee;

  Movement({
    required this.id,
    required this.concept,
    required this.amount,
    this.cur = 'COP',
    this.account = '',
    this.date = '',
    this.projectId,
    this.fee = false,
  });

  factory Movement.fromJson(Map<String, dynamic> j) => Movement(
        id: asStr(j['id'], newId()),
        concept: asStr(j['concept']),
        amount: asNum(j['amount']),
        cur: asStr(j['cur'], 'COP'),
        account: asStr(j['account']),
        date: asStr(j['date']),
        projectId: j['projectId'] == null ? null : asStr(j['projectId']),
        fee: asBool(j['fee']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'concept': concept,
        'amount': amount,
        'cur': cur,
        'account': account,
        'date': date,
        if (projectId != null) 'projectId': projectId,
        if (fee) 'fee': true,
      };
}
