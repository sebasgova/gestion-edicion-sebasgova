import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/project_form.dart';
import '../forms/task_form.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// Agenda combinada de entregas de proyectos y tareas con fecha.
class DeliveriesScreen extends StatelessWidget {
  final AppState state;
  const DeliveriesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    final items = <_Item>[
      for (final p in d.projects.where((p) => p.stage != 'delivered' && p.due.isNotEmpty))
        _Item(
          date: p.due,
          title: p.title,
          sub: '${p.client.isEmpty ? 'Sin cliente' : p.client} · ${p.service} · ${AppConst.workStage(p.stage).name}',
          isProject: true,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ProjectForm(state: state, initial: p))),
        ),
      for (final t in d.tasks.where((t) => !t.done && t.due.isNotEmpty))
        _Item(
          date: t.due,
          title: t.text,
          sub: t.client.isEmpty ? 'Sin cliente' : t.client,
          isProject: false,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => TaskForm(state: state, initial: t))),
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    final week = items.where((e) {
      final dl = daysLeft(e.date);
      return dl != null && dl >= 0 && dl <= 7;
    }).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Entregas',
        subtitle: 'Agenda combinada: proyectos y tareas con fecha · $week en los próximos 7 días',
      ),
      Expanded(
        child: items.isEmpty
            ? const EmptyState(icon: Icons.event_available_outlined, text: 'Sin entregas ni tareas con fecha')
            : ListView.separated(
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (i == items.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: ComingSoonTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Calendario mensual',
                          description: 'Vista de calendario con las tareas por día'),
                    );
                  }
                  return _row(items[i]);
                },
              ),
      ),
    ]);
  }

  Widget _row(_Item it) {
    final dl = daysLeft(it.date);
    final color = dl == null
        ? AppColors.textFaint
        : dl < 0
            ? AppColors.red
            : dl <= 3
                ? AppColors.amber
                : AppColors.green;
    return AppCard(
      onTap: it.onTap,
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        SizedBox(width: 96, child: Text(fmtDay(it.date), style: AppTextStyles.subtitle)),
        Pill(it.isProject ? 'Proyecto' : 'Tarea', it.isProject ? AppColors.blue : AppColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.title, style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
            Text(it.sub, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Text(dueLabel(dl), style: AppTextStyles.bodyDim.copyWith(color: color)),
      ]),
    );
  }
}

class _Item {
  final String date;
  final String title;
  final String sub;
  final bool isProject;
  final VoidCallback onTap;
  _Item({
    required this.date,
    required this.title,
    required this.sub,
    required this.isProject,
    required this.onTap,
  });
}
