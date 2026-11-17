import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../models/movement.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

class MovementForm extends StatefulWidget {
  final AppState state;
  final bool isIncome;
  final Movement? initial;
  const MovementForm({super.key, required this.state, required this.isIncome, this.initial});

  @override
  State<MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<MovementForm> {
  final formKey = GlobalKey<FormState>();
  late final concept = TextEditingController(text: widget.initial?.concept ?? '');
  late final date = TextEditingController(text: widget.initial?.date ?? todayIso());
  late final amount = TextEditingController(
      text: moneyToField(widget.initial?.amount ?? 0, widget.initial?.cur ?? 'COP'));
  late String cur = widget.initial?.cur ?? 'COP';
  late String account = widget.initial?.account ?? widget.state.data.accounts.first.id;

  @override
  void dispose() {
    concept.dispose();
    date.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);
    final prev = widget.initial;
    await widget.state.saveMovement(
      widget.isIncome,
      Movement(
        id: prev?.id ?? newId(),
        concept: concept.text.trim(),
        amount: parseMoney(amount.text, cur),
        cur: cur,
        account: account,
        date: date.text.isEmpty ? todayIso() : date.text,
        projectId: prev?.projectId,
        fee: prev?.fee ?? false,
      ),
    );
    if (mounted) {
      toast(context, 'Movimiento guardado');
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    final accounts = widget.state.data.accounts;
    return FormPage(
      title: '${editing ? 'Editar' : 'Nuevo'} ${widget.isIncome ? 'ingreso' : 'gasto'}',
      formKey: formKey,
      onSave: save,
      onDelete: editing
          ? () => widget.state.deleteMovement(widget.isIncome, widget.initial!.id)
          : null,
      deleteTitle: 'Eliminar movimiento',
      deleteBody: widget.initial?.projectId != null
          ? 'Este ingreso viene de un pago de proyecto; el pago también se quitará.'
          : '¿Eliminar este movimiento?',
      children: [
        AppTextField(
            controller: concept,
            label: 'Concepto',
            autofocus: !editing,
            validator: (v) => requiredText(v, 'Ponle un concepto al movimiento')),
        MoneyRow(
            amount: amount, cur: cur, required: true, onCurChanged: (v) => setState(() => cur = v)),
        AppDropdown(
            label: 'Cuenta',
            value: account,
            options: accounts.map((a) => a.id).toList(),
            labels: {for (final a in accounts) a.id: '${a.name} (${a.cur})'},
            onChanged: (v) => setState(() => account = v ?? account)),
        DateField(controller: date, label: 'Fecha'),
      ],
    );
  }
}
