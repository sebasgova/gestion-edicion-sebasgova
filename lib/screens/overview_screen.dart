import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class OverviewScreen extends StatelessWidget {
  final AppState state;
  final void Function(int) navigate;
  const OverviewScreen({super.key, required this.state, required this.navigate});

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    final active = d.projects.where((p) => p.stage != 'delivered').toList();
    final openTasks = d.tasks.where((t) => !t.done).length;
    final openLeads = d.leads.where((l) => l.stage != 'won' && l.stage != 'lost').length;
    final weekItems = <_Due>[
      for (final p in active.where((p) => p.due.isNotEmpty))
        _Due(p.title, p.client, p.due, 'Proyecto'),
      for (final t in d.tasks.where((t) => !t.done && t.due.isNotEmpty))
        _Due(t.text, t.client, t.due, 'Tarea'),
    ]..sort((a, b) => a.date.compareTo(b.date));
    final upcoming = weekItems.take(5).toList();
    final overdue = weekItems.where((e) => (daysLeft(e.date) ?? 0) < 0).length;

    return ListView(children: [
      const SectionHeader(
          title: 'Resumen', subtitle: 'Tu espacio de producción audiovisual'),
      ResponsiveGrid(minTileWidth: 210, children: [
        KpiCard(
            label: 'Proyectos activos',
            value: '${active.length}',
            meta: '${d.projects.length} en total',
            icon: Icons.movie_creation_outlined,
            onTap: () => navigate(2)),
        KpiCard(
            label: 'Prospectos abiertos',
            value: '$openLeads',
            meta: 'En el pipeline',
            icon: Icons.account_tree_outlined,
            accent: AppColors.purple,
            onTap: () => navigate(1)),
        KpiCard(
            label: 'Tareas pendientes',
            value: '$openTasks',
            meta: overdue > 0 ? '$overdue vencida(s)' : 'Al día',
            icon: Icons.task_alt,
            accent: overdue > 0 ? AppColors.red : AppColors.green,
            onTap: () => navigate(4)),
        KpiCard(
            label: 'Por cobrar',
            value: fmtCop(state.receivableTotalCop),
            meta: '${state.receivables().length} proyecto(s)',
            icon: Icons.request_quote_outlined,
            accent: AppColors.gold,
            onTap: () => navigate(5)),
        KpiCard(
            label: 'Ingresos del mes',
            value: fmtCop(state.incomeThisMonthCop),
            meta: 'Gastos ${fmtCop(state.expensesThisMonthCop)}',
            icon: Icons.trending_up,
            accent: AppColors.green,
            onTap: () => navigate(5)),
        KpiCard(
            label: 'Saldo total (COP)',
            value: fmtCop(state.totalBalanceCop),
            meta: 'Todas las cuentas',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => navigate(5)),
      ]),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 760;
        final left = _upcomingCard(context, upcoming);
        final right = _stagesCard(context);
        if (!wide) return Column(children: [left, const SizedBox(height: 12), right]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: left),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: right),
        ]);
      }),
      if (d.projects.isEmpty && d.clients.isEmpty && d.leads.isEmpty) ...[
        const SizedBox(height: 18),
        AppCard(
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('Aún no hay datos. Puedes empezar creando un cliente o '
                    'cargar datos de ejemplo desde Ajustes.')),
            TextButton(onPressed: () => navigate(7), child: const Text('Ir a Ajustes')),
          ]),
        ),
      ],
    ]);
  }

  Widget _upcomingCard(BuildContext context, List<_Due> items) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Próximas entregas', style: AppTextStyles.title)),
            TextButton(onPressed: () => navigate(6), child: const Text('Ver todas')),
          ]),
          if (items.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('Sin entregas ni tareas con fecha', style: AppTextStyles.bodyDim)),
          for (final it in items) _dueRow(it),
        ]),
      );

  Widget _dueRow(_Due it) {
    final dl = daysLeft(it.date);
    final color = dl == null
        ? AppColors.textFaint
        : dl < 0
            ? AppColors.red
            : dl <= 3
                ? AppColors.amber
                : AppColors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.title, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
            Text('${it.kind}${it.client.isEmpty ? '' : ' · ${it.client}'} · ${fmtDay(it.date)}',
                style: AppTextStyles.caption),
          ]),
        ),
        Text(dueLabel(dl), style: AppTextStyles.bodyDim.copyWith(color: color)),
      ]),
    );
  }

  Widget _stagesCard(BuildContext context) {
    final projects = state.data.projects;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Proyectos por etapa', style: AppTextStyles.title),
        const SizedBox(height: 12),
        for (final s in AppConst.workStages)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Container(
                  width: 9, height: 9, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.name, style: AppTextStyles.bodyDim)),
              Text('${projects.where((p) => p.stage == s.id).length}', style: AppTextStyles.subtitle),
            ]),
          ),
      ]),
    );
  }
}

class _Due {
  final String title;
  final String client;
  final String date;
  final String kind;
  _Due(this.title, this.client, this.date, this.kind);
}
