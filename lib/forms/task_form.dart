import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/task_item.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

class TaskForm extends StatefulWidget {
  final AppState state;
  final TaskItem? initial;
  const TaskForm({super.key, required this.state, this.initial});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final formKey = GlobalKey<FormState>();
  late final text = TextEditingController(text: widget.initial?.text ?? '');
  late final due = TextEditingController(text: widget.initial?.due ?? '');
  late String client = widget.initial?.client ?? '';
  late String prio = widget.initial?.prio ?? 'media';

  @override
  void dispose() {
    text.dispose();
    due.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);
    await widget.state.saveTask(TaskItem(
      id: widget.initial?.id ?? newId(),
      text: text.text.trim(),
      client: client,
      prio: prio,
      due: due.text,
      done: widget.initial?.done ?? false,
    ));
    if (mounted) {
      toast(context, 'Tarea guardada');
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return FormPage(
      title: editing ? 'Editar tarea' : 'Nueva tarea',
      formKey: formKey,
      onSave: save,
      onDelete: editing ? () => widget.state.deleteTask(widget.initial!.id) : null,
      deleteTitle: 'Eliminar tarea',
      deleteBody: '¿Eliminar esta tarea?',
      children: [
        AppTextField(
            controller: text,
            label: '¿Qué hay que hacer?',
            autofocus: !editing,
            maxLines: 2,
            validator: (v) => requiredText(v, 'Escribe qué hay que hacer')),
        AppDropdown(
            label: 'Cliente (opcional)',
            value: client,
            options: ['', ...widget.state.data.clients.map((c) => c.name)],
            onChanged: (v) => setState(() => client = v ?? '')),
        AppDropdown(
            label: 'Prioridad',
            value: prio,
            options: AppConst.priorities.keys.toList(),
            labels: AppConst.priorities,
            onChanged: (v) => setState(() => prio = v ?? prio)),
        DateField(controller: due, label: 'Fecha (opcional)'),
      ],
    );
  }
}
