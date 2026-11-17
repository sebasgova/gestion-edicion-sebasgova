import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/project.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

class ProjectForm extends StatefulWidget {
  final AppState state;
  final Project? initial;
  const ProjectForm({super.key, required this.state, this.initial});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final formKey = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.initial?.title ?? '');
  late final due = TextEditingController(text: widget.initial?.due ?? '');
  late final drive = TextEditingController(text: widget.initial?.drive ?? '');
  late final price = TextEditingController(
      text: moneyToField(widget.initial?.price ?? 0, widget.initial?.cur ?? 'COP'));
  late final revUsed = TextEditingController(text: '${widget.initial?.revUsed ?? 0}');
  late final revMax = TextEditingController(text: '${widget.initial?.revMax ?? 2}');
  late String client = widget.initial?.client ?? '';
  late String service = widget.initial?.service ?? AppConst.services.first;
  late String stage = widget.initial?.stage ?? AppConst.workStages.first.id;
  late String cur = widget.initial?.cur ?? 'COP';
  late String editor = widget.initial?.editor ?? '';

  @override
  void dispose() {
    for (final c in [title, due, drive, price, revUsed, revMax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);
    final prev = widget.initial;
    await widget.state.saveProject(Project(
      id: prev?.id ?? newId(),
      title: title.text.trim(),
      client: client,
      service: service,
      stage: stage,
      due: due.text,
      price: parseMoney(price.text, cur),
      cur: cur,
      revUsed: int.tryParse(revUsed.text) ?? 0,
      revMax: int.tryParse(revMax.text) ?? 0,
      editor: editor,
      drive: drive.text.trim(),
      payments: prev?.payments,
      extra: prev?.extra,
    ));
    if (mounted) {
      toast(context, 'Proyecto guardado');
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    final clients = ['', ...widget.state.data.clients.map((c) => c.name)];
    final editors = ['', ...widget.state.data.editors];
    return FormPage(
      title: editing ? 'Editar proyecto' : 'Nuevo proyecto',
      formKey: formKey,
      onSave: save,
      onDelete: editing ? () => widget.state.deleteProject(widget.initial!.id) : null,
      deleteTitle: 'Eliminar proyecto',
      deleteBody:
          '¿Eliminar "${widget.initial?.title}"? También se quitarán los ingresos generados por sus pagos.',
      children: [
        AppTextField(
            controller: title,
            label: 'Título del proyecto',
            autofocus: !editing,
            validator: (v) => requiredText(v, 'Ponle un título al proyecto')),
        AppDropdown(
            label: 'Cliente',
            value: client,
            options: clients,
            onChanged: (v) => setState(() => client = v ?? '')),
        AppDropdown(
            label: 'Servicio',
            value: service,
            options: AppConst.services,
            onChanged: (v) => setState(() => service = v ?? service)),
        AppDropdown(
            label: 'Etapa',
            value: stage,
            options: AppConst.workStages.map((s) => s.id).toList(),
            labels: {for (final s in AppConst.workStages) s.id: s.name},
            onChanged: (v) => setState(() => stage = v ?? stage)),
        DateField(controller: due, label: 'Fecha de entrega'),
        MoneyRow(
            amount: price,
            cur: cur,
            label: 'Precio',
            onCurChanged: (v) => setState(() => cur = v)),
        Row(children: [
          Expanded(
              child: AppTextField(
                  controller: revUsed,
                  label: 'Revisiones usadas',
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(
              child: AppTextField(
                  controller: revMax,
                  label: 'Revisiones incluidas',
                  keyboardType: TextInputType.number)),
        ]),
        AppDropdown(
            label: 'Editor',
            value: editor,
            options: editors,
            onChanged: (v) => setState(() => editor = v ?? '')),
        AppTextField(controller: drive, label: 'Carpeta de Drive'),
      ],
    );
  }
}
