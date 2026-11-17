import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/payment_form.dart';
import '../forms/project_form.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// Ficha del proyecto: datos, progreso de cobro y pagos registrados.
class ProjectDetailScreen extends StatelessWidget {
  final AppState state;
  final String projectId;
  const ProjectDetailScreen({super.key, required this.state, required this.projectId});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          final p = state.projectById(projectId);
          if (p == null) {
            return Scaffold(
                appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, text: 'Proyecto no encontrado'));
          }
          final stage = AppConst.workStage(p.stage);
          final totalCop = state.toCop(p.price, p.cur);
          final paidCop = state.projectPaidCop(p);
          final pct = totalCop <= 0 ? 0.0 : (paidCop / totalCop).clamp(0.0, 1.0);
          final pending = state.projectPendingNative(p);
          final dl = daysLeft(p.due);

          return Scaffold(
            appBar: AppBar(
              title: Text(p.title, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProjectForm(state: state, initial: p))),
                ),
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        Pill(stage.name, stage.color),
                        if (p.client.isNotEmpty) Pill(p.client, AppColors.blue),
                        if (p.service.isNotEmpty) Pill(p.service, AppColors.purple),
                      ]),
                      const SizedBox(height: 14),
                      _row('Entrega', p.due.isEmpty ? 'Sin fecha' : '${fmtDay(p.due)} · ${dueLabel(dl)}'),
                      _row('Editor', p.editor.isEmpty ? '—' : p.editor),
                      _row('Revisiones', '${p.revUsed} de ${p.revMax}'),
                      if (p.drive.isNotEmpty) _row('Drive', p.drive),
                      const SizedBox(height: 10),
                      const Text('Mover a etapa', style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in AppConst.workStages)
                          ChoiceChip(
                            label: Text(s.name),
                            selected: s.id == p.stage,
                            selectedColor: AppColors.panel3,
                            onSelected: (_) => state.moveProject(p.id, s.id),
                          ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Expanded(child: Text('Cobro', style: AppTextStyles.title)),
                        if (p.price > 0 && pending > 0)
                          FilledButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Registrar pago'),
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => PaymentForm(state: state, project: p))),
                          ),
                      ]),
                      const SizedBox(height: 10),
                      if (p.price <= 0)
                        const Text('Este proyecto no tiene precio. Agrégalo al editarlo para llevar el cobro.',
                            style: AppTextStyles.bodyDim)
                      else ...[
                        Row(children: [
                          Expanded(child: Text('Precio ${fmtNative(p.price, p.cur)}', style: AppTextStyles.body)),
                          Text(pct >= 1 ? 'Cobrado' : '${(pct * 100).round()}% cobrado',
                              style: AppTextStyles.bodyDim),
                        ]),
                        const SizedBox(height: 8),
                        ThinBar(value: pct, color: pct >= 1 ? AppColors.green : AppColors.gold),
                        const SizedBox(height: 6),
                        Text(
                            pending > 0
                                ? 'Pendiente ${fmtNative(pending, p.cur)}'
                                : 'Sin saldo pendiente',
                            style: AppTextStyles.caption),
                      ],
                      const SizedBox(height: 12),
                      if (p.payments.isEmpty)
                        const Text('Aún no hay pagos registrados.', style: AppTextStyles.caption),
                      for (final pay in p.payments)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline, color: AppColors.green),
                          title: Text(fmtNative(pay.amount, pay.cur), style: AppTextStyles.subtitle),
                          subtitle: Text('${state.accountName(pay.account)} · ${fmtDay(pay.date)}',
                              style: AppTextStyles.caption),
                          trailing: IconButton(
                            tooltip: 'Revertir pago',
                            icon: const Icon(Icons.undo, size: 20),
                            onPressed: () async {
                              final ok = await confirmDialog(context,
                                  title: 'Revertir pago',
                                  body: 'Se quitará el pago y el ingreso que generó.',
                                  okLabel: 'Revertir');
                              if (ok) {
                                await state.undoPayment(p.id, pay.id);
                                if (context.mounted) toast(context, 'Pago revertido');
                              }
                            },
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  const ComingSoonTile(
                      icon: Icons.video_library_outlined,
                      title: 'Videos y lotes del proyecto mensual',
                      description: 'Seguimiento de cada video por etapa'),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar proyecto'),
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final ok = await confirmDialog(context,
                          title: 'Eliminar proyecto',
                          body: '¿Eliminar "${p.title}"? También se quitarán los ingresos de sus pagos.');
                      if (!ok) return;
                      await state.deleteProject(p.id);
                      nav.pop();
                    },
                  ),
                ]),
              ),
            ),
          );
        },
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 100, child: Text(k, style: AppTextStyles.bodyDim)),
          Expanded(child: Text(v, style: AppTextStyles.body)),
        ]),
      );
}
