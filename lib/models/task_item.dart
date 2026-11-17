import '../core/utils.dart';

class TaskItem {
  final String id;
  String text;
  String client;
  String prio; // alta | media | baja
  String due;
  bool done;

  TaskItem({
    required this.id,
    required this.text,
    this.client = '',
    this.prio = 'media',
    this.due = '',
    this.done = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
        id: asStr(j['id'], newId()),
        text: asStr(j['text']),
        client: asStr(j['client']),
        prio: asStr(j['prio'], 'media'),
        due: asStr(j['due']),
        done: asBool(j['done']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'client': client,
        'prio': prio,
        'due': due,
        'done': done,
      };
}
