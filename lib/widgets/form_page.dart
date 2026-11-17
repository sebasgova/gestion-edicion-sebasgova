import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'common.dart';

/// Estructura común de los formularios (crear / editar / eliminar).
class FormPage extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSave;
  final Future<void> Function()? onDelete;
  final String deleteTitle;
  final String deleteBody;
  final String saveLabel;

  const FormPage({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.onDelete,
    this.deleteTitle = 'Eliminar',
    this.deleteBody = 'Esta acción no se puede deshacer.',
    this.saveLabel = 'Guardar',
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (onDelete != null)
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                onPressed: () async {
                  final ok = await confirmDialog(context, title: deleteTitle, body: deleteBody);
                  if (!ok) return;
                  await onDelete!();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ...children,
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(saveLabel),
                        onPressed: onSave,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
}
