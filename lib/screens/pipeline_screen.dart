import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/lead_form.dart';
import '../models/lead.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class PipelineScreen extends StatelessWidget {
  final AppState state;
  const PipelineScreen({super.key, required this.state});

  void _open(BuildContext context, [Lead? lead]) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => LeadForm(state: state, initial: lead)));

  Future<void> _move(BuildContext context, Lead lead, String stage) async {
    if (stage == lead.stage) return;
    if (stage == 'lost') {
      final reason = await _askReason(context);
      if (reason == null) return;
      await state.moveLead(lead.id, stage, lostReason: reason);
      return;
    }
    await state.moveLead(lead.id, stage);
    if (stage == 'won' && context.mounted) {
      await offerClientFromLead(context, state, lead.id);
    }
  }

  Future<String?> _askReason(BuildContext context) => showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          backgroundColor: AppColors.panel,
          title: const Text('¿Por qué se perdió?', style: AppTextStyles.title),
          children: [
            for (final r in AppConst.lostReasons)
              SimpleDialogOption(onPressed: () => Navigator.pop(ctx, r), child: Text(r)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final leads = state.data.leads;
    final won = leads.where((l) => l.stage == 'won').length;
    final lost = leads.where((l) => l.stage == 'lost').length;
    final open = leads.where((l) => l.stage != 'won' && l.stage != 'lost').toList();
    final openValue = open.fold(0.0, (s, l) => s + state.toCop(l.value, l.cur));
    final closed = won + lost;
    final rate = closed == 0 ? '—' : '${(won / closed * 100).round()}%';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Pipeline',
        subtitle: 'Prospectos de venta, de lead a cliente',
        actions: [
          FilledButton.icon(
              onPressed: () => _open(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Prospecto')),
        ],
      ),
      Wrap(spacing: 10, runSpacing: 10, children: [
        _stat('Abiertos', '${open.length}'),
        _stat('Valor en juego', fmtCop(openValue)),
        _stat('Tasa de cierre', rate),
        _stat('Ganados / perdidos', '$won / $lost'),
      ]),
      const SizedBox(height: 16),
      Expanded(
        child: leads.isEmpty
            ? const EmptyState(
                icon: Icons.account_tree_outlined,
                text: 'Aún no tienes prospectos',
                hint: 'Crea el primero con el botón "Prospecto".')
            : ListView(scrollDirection: Axis.horizontal, children: [
                for (final stage in AppConst.leadStages) _column(context, stage, leads),
              ]),
      ),
    ]);
  }

  Widget _stat(String label, String value) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.title),
        ]),
      );

  Widget _column(BuildContext context, StageDef stage, List<Lead> all) {
    final items = all.where((l) => l.stage == stage.id).toList();
    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.raised,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: stage.color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(stage.name, style: AppTextStyles.subtitle)),
            Text('${items.length}', style: AppTextStyles.bodyDim),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: items.isEmpty
              ? Center(child: Text(stage.desc, style: AppTextStyles.caption, textAlign: TextAlign.center))
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children: [for (final l in items) _leadCard(context, l)],
                ),
        ),
      ]),
    );
  }

  Widget _leadCard(BuildContext context, Lead l) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          onTap: () => _open(context, l),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.name, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                if (l.value > 0) Text(fmtNative(l.value, l.cur), style: AppTextStyles.bodyDim),
                if (l.service.isNotEmpty) Text(l.service, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (l.source.isNotEmpty) Pill(l.source, AppConst.sourceColor(l.source)),
                  if (l.stage == 'lost' && l.lostReason.isNotEmpty) Pill(l.lostReason, AppColors.red),
                ]),
              ]),
            ),
            PopupMenuButton<String>(
              tooltip: 'Mover a...',
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textDim),
              onSelected: (s) => _move(context, l, s),
              itemBuilder: (_) => [
                for (final s in AppConst.leadStages)
                  if (s.id != l.stage) PopupMenuItem(value: s.id, child: Text('Mover a ${s.name}')),
              ],
            ),
          ]),
        ),
      );
}
