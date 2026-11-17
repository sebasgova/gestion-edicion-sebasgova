import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../models/project.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/fields.dart';
import '../widgets/form_page.dart';

/// Registrar un pago recibido de un proyecto. Crea el ingreso enlazado.
class PaymentForm extends StatefulWidget {
  final AppState state;
  final Project project;
  const PaymentForm({super.key, required this.state, required this.project});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final formKey = GlobalKey<FormState>();
  late final amount = TextEditingController(
      text: moneyToField(widget.state.projectPendingNative(widget.project), widget.project.cur));
  final date = TextEditingController(text: todayIso());
  late String cur = widget.project.cur;
  late String account = widget.state.data.accounts.first.id;

  @override
  void dispose() {
    amount.dispose();
    date.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);
    await widget.state.addPayment(
      widget.project.id,
      parseMoney(amount.text, cur),
      cur,
      account,
      date.text.isEmpty ? todayIso() : date.text,
    );
    if (mounted) {
      toast(context, 'Pago registrado en ${widget.state.accountName(account)}');
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.state.data.accounts;
    final p = widget.project;
    return FormPage(
      title: 'Registrar pago',
      saveLabel: 'Registrar',
      formKey: formKey,
      onSave: save,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('${p.title} · precio ${fmtNative(p.price, p.cur)}'),
        ),
        MoneyRow(
            amount: amount,
            cur: cur,
            label: 'Cuánto te pagaron',
            required: true,
            onCurChanged: (v) => setState(() => cur = v)),
        AppDropdown(
            label: 'Cuenta donde entró',
            value: account,
            options: accounts.map((a) => a.id).toList(),
            labels: {for (final a in accounts) a.id: '${a.name} (${a.cur})'},
            onChanged: (v) => setState(() => account = v ?? account)),
        DateField(controller: date, label: 'Fecha del pago'),
      ],
    );
  }
}
