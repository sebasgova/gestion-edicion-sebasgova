import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/utils.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          autofocus: autofocus,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}

/// Lista desplegable de texto. [labels] permite mostrar un nombre distinto al valor guardado.
class AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final Map<String, String>? labels;
  final ValueChanged<String?> onChanged;
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final items = options.toSet().toList();
    if (value != null && value!.isNotEmpty && !items.contains(value)) items.insert(0, value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: (value != null && items.contains(value)) ? value : null,
        isExpanded: true,
        dropdownColor: AppColors.panel2,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final o in items)
            DropdownMenuItem(
              value: o,
              child: Text(labels?[o] ?? (o.isEmpty ? '— Ninguno —' : o),
                  overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Campo de fecha que abre el selector del sistema. Guarda ISO yyyy-MM-dd.
class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const DateField({super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              hintText: 'Sin fecha',
              suffixIcon: value.text.isEmpty
                  ? const Icon(Icons.calendar_month_outlined, size: 20)
                  : IconButton(
                      tooltip: 'Quitar fecha',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => controller.clear(),
                    ),
            ),
            onTap: () async {
              final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.text = isoOf(picked);
            },
          ),
        ),
      );
}

/// Monto + moneda en una misma fila.
class MoneyRow extends StatelessWidget {
  final TextEditingController amount;
  final String cur;
  final ValueChanged<String> onCurChanged;
  final String label;
  final bool required;
  const MoneyRow({
    super.key,
    required this.amount,
    required this.cur,
    required this.onCurChanged,
    this.label = 'Monto',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: label),
              validator: (v) {
                if (!required && (v == null || v.trim().isEmpty)) return null;
                return parseMoney(v ?? '', cur) <= 0 ? 'Escribe un monto' : null;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: cur,
              isExpanded: true,
              dropdownColor: AppColors.panel2,
              decoration: const InputDecoration(labelText: 'Moneda'),
              items: [
                for (final c in AppConst.currencies) DropdownMenuItem(value: c, child: Text(c))
              ],
              onChanged: (v) => onCurChanged(v ?? cur),
            ),
          ),
        ]),
      );
}

String? requiredText(String? v, String message) =>
    (v == null || v.trim().isEmpty) ? message : null;
