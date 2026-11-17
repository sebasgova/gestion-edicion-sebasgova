import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/client.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

class ClientForm extends StatefulWidget {
  final AppState state;
  final Client? initial;
  const ClientForm({super.key, required this.state, this.initial});

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial?.name ?? '');
  late final contact = TextEditingController(text: widget.initial?.contact ?? '');
  late final rate = TextEditingController(text: widget.initial?.rate ?? '');
  late final drive = TextEditingController(text: widget.initial?.drive ?? '');
  late final notes = TextEditingController(text: widget.initial?.notes ?? '');
  late String type = widget.initial?.type ?? AppConst.services.first;
  late String status = widget.initial?.status ?? 'active';

  @override
  void dispose() {
    for (final c in [name, contact, rate, drive, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);
    await widget.state.saveClient(Client(
      id: widget.initial?.id ?? newId(),
      name: name.text.trim(),
      contact: contact.text.trim(),
      type: type,
      rate: rate.text.trim(),
      status: status,
      drive: drive.text.trim(),
      notes: notes.text.trim(),
    ));
    if (mounted) {
      toast(context, 'Cliente guardado');
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return FormPage(
      title: editing ? 'Editar cliente' : 'Nuevo cliente',
      formKey: formKey,
      onSave: save,
      onDelete: editing ? () => widget.state.deleteClient(widget.initial!.id) : null,
      deleteTitle: 'Eliminar cliente',
      deleteBody: '¿Eliminar a "${widget.initial?.name}"? Sus proyectos no se borran.',
      children: [
        AppTextField(
            controller: name,
            label: 'Nombre',
            autofocus: !editing,
            validator: (v) => requiredText(v, 'Ponle nombre al cliente')),
        AppTextField(controller: contact, label: 'Contacto (email / IG)'),
        AppDropdown(
            label: 'Servicio principal',
            value: type,
            options: AppConst.services,
            onChanged: (v) => setState(() => type = v ?? type)),
        AppTextField(controller: rate, label: 'Tarifa / nota de precio', hint: '€350/video'),
        AppDropdown(
            label: 'Estado',
            value: status,
            options: AppConst.clientStatuses.keys.toList(),
            labels: AppConst.clientStatuses,
            onChanged: (v) => setState(() => status = v ?? status)),
        AppTextField(controller: drive, label: 'Carpeta de Drive', hint: 'https://drive.google.com/...'),
        AppTextField(controller: notes, label: 'Notas', maxLines: 3),
      ],
    );
  }
}
