import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/lead.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

class LeadForm extends StatefulWidget {
  final AppState state;
  final Lead? initial;
  const LeadForm({super.key, required this.state, this.initial});

  @override
  State<LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends State<LeadForm> {
  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial?.name ?? '');
  late final contact = TextEditingController(text: widget.initial?.contact ?? '');
  late final notes = TextEditingController(text: widget.initial?.notes ?? '');
  late final value = TextEditingController(
      text: moneyToField(widget.initial?.value ?? 0, widget.initial?.cur ?? 'USD'));
  late String source = widget.initial?.source ?? AppConst.leadSources.first;
  late String service = widget.initial?.service ?? AppConst.services.first;
  late String cur = widget.initial?.cur ?? 'USD';
  late String stage = widget.initial?.stage ?? AppConst.leadStages.first.id;
  late String lostReason = widget.initial?.lostReason ?? '';

  @override
  void dispose() {
    for (final c in [name, contact, notes, value]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (stage == 'lost' && lostReason.isEmpty) {
      toast(context, 'Indica por qué se perdió el prospecto');
      return;
    }
    final nav = Navigator.of(context);
    final id = widget.initial?.id ?? newId();
    final wasWon = widget.initial?.stage == 'won';
    await widget.state.saveLead(Lead(
      id: id,
      name: name.text.trim(),
      contact: contact.text.trim(),
      source: source,
      service: service,
      value: parseMoney(value.text, cur),
      cur: cur,
      stage: stage,
      notes: notes.text.trim(),
      lostReason: stage == 'lost' ? lostReason : '',
    ));
    if (!mounted) return;
    nav.pop();
    if (stage == 'won' && !wasWon) {
      // La pantalla anterior ofrece crear el cliente.
      await offerClientFromLead(nav.context, widget.state, id);
    } else {
      toast(nav.context, 'Prospecto guardado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return FormPage(
      title: editing ? 'Editar prospecto' : 'Nuevo prospecto',
      formKey: formKey,
      onSave: save,
      onDelete: editing ? () => widget.state.deleteLead(widget.initial!.id) : null,
      deleteTitle: 'Eliminar prospecto',
      deleteBody: '¿Eliminar a "${widget.initial?.name}" del pipeline?',
      children: [
        AppTextField(
            controller: name,
            label: 'Nombre',
            autofocus: !editing,
            validator: (v) => requiredText(v, 'Ponle nombre al prospecto')),
        AppTextField(controller: contact, label: 'Contacto'),
        AppDropdown(
            label: 'Fuente',
            value: source,
            options: AppConst.leadSources,
            onChanged: (v) => setState(() => source = v ?? source)),
        AppDropdown(
            label: 'Servicio de interés',
            value: service,
            options: AppConst.services,
            onChanged: (v) => setState(() => service = v ?? service)),
        MoneyRow(
            amount: value,
            cur: cur,
            label: 'Valor estimado',
            onCurChanged: (v) => setState(() => cur = v)),
        AppDropdown(
            label: 'Etapa',
            value: stage,
            options: AppConst.leadStages.map((s) => s.id).toList(),
            labels: {for (final s in AppConst.leadStages) s.id: s.name},
            onChanged: (v) => setState(() => stage = v ?? stage)),
        if (stage == 'lost')
          AppDropdown(
              label: 'Razón de pérdida',
              value: lostReason,
              options: ['', ...AppConst.lostReasons],
              onChanged: (v) => setState(() => lostReason = v ?? '')),
        AppTextField(controller: notes, label: 'Notas', maxLines: 3),
      ],
    );
  }
}

/// Cuando un prospecto se gana, ofrece crearlo como cliente.
Future<void> offerClientFromLead(BuildContext context, AppState state, String leadId) async {
  final lead = state.data.leads.firstWhere((l) => l.id == leadId);
  if (state.clientExists(lead.name)) {
    toast(context, '¡Ganado! Ese cliente ya existe en tu cartera');
    return;
  }
  final ok = await confirmDialog(
    context,
    title: '¡Prospecto ganado!',
    body: '${lead.name} cerró. ¿Crearlo como cliente en tu cartera? '
        'Se copiarán su contacto, servicio y valor.',
    okLabel: 'Crear cliente',
    danger: false,
  );
  if (!ok) return;
  await state.convertLeadToClient(leadId);
  if (context.mounted) toast(context, 'Cliente creado desde el prospecto');
}
