import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/task_form.dart';
import '../models/task_item.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class TasksScreen extends StatefulWidget {
  final AppState state;
  const TasksScreen({super.key, required this.state});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String filter = 'open'; // open | done | all
  String search = '';

  AppState get state => widget.state;

  void _open([TaskItem? t]) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => TaskForm(state: state, initial: t)));

  Color _prioColor(String p) =>
      p == 'alta' ? AppColors.red : p == 'media' ? AppColors.amber : AppColors.green;

  int _prioRank(String p) => p == 'alta' ? 0 : p == 'media' ? 1 : 2;

  @override
  Widget build(BuildContext context) {
    final all = state.data.tasks;
    final q = search.toLowerCase();
    final items = all
        .where((t) =>
            (filter == 'all' || (filter == 'done') == t.done) &&
            '${t.text} ${t.client}'.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        final byPrio = _prioRank(a.prio).compareTo(_prioRank(b.prio));
        if (byPrio != 0) return byPrio;
        return (a.due.isEmpty ? '9999' : a.due).compareTo(b.due.isEmpty ? '9999' : b.due);
      });
    final doneCount = all.where((t) => t.done).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Pendientes',
        subtitle: '${all.length - doneCount} por hacer · $doneCount hechas',
        actions: [
          if (doneCount > 0)
            OutlinedButton.icon(
              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
              label: const Text('Limpiar hechas'),
              onPressed: () async {
                final ok = await confirmDialog(context,
                    title: 'Limpiar tareas hechas',
                    body: 'Se eliminarán $doneCount tarea(s) completadas.',
                    okLabel: 'Limpiar');
                if (ok) await state.clearDoneTasks();
              },
            ),
          FilledButton.icon(
              onPressed: () => _open(), icon: const Icon(Icons.add, size: 18), label: const Text('Tarea')),
        ],
      ),
      Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(
          width: 300,
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar tareas'),
          ),
        ),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'open', label: Text('Por hacer')),
            ButtonSegment(value: 'done', label: Text('Hechas')),
            ButtonSegment(value: 'all', label: Text('Todas')),
          ],
          selected: {filter},
          onSelectionChanged: (s) => setState(() => filter = s.first),
        ),
      ]),
      const SizedBox(height: 14),
      Expanded(
        child: items.isEmpty
            ? EmptyState(
                icon: Icons.task_alt,
                text: all.isEmpty ? 'Sin tareas todavía' : 'No hay tareas en esta vista',
                hint: all.isEmpty ? 'Crea la primera con el botón "Tarea".' : null)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _row(items[i]),
              ),
      ),
    ]);
  }

  Widget _row(TaskItem t) {
    final dl = daysLeft(t.due);
    final overdue = !t.done && dl != null && dl < 0;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      onTap: () => _open(t),
      child: Row(children: [
        Checkbox(value: t.done, onChanged: (_) => state.toggleTask(t.id)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              t.text,
              style: AppTextStyles.subtitle.copyWith(
                decoration: t.done ? TextDecoration.lineThrough : null,
                color: t.done ? AppColors.textFaint : AppColors.text,
              ),
            ),
            Text(t.client.isEmpty ? 'Sin cliente' : t.client, style: AppTextStyles.caption),
          ]),
        ),
        if (t.due.isNotEmpty && !t.done)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text('${fmtDay(t.due)} · ${dueLabel(dl)}',
                style: AppTextStyles.caption.copyWith(color: overdue ? AppColors.red : AppColors.textDim)),
          ),
        Pill(AppConst.priorities[t.prio] ?? t.prio, _prioColor(t.prio)),
      ]),
    );
  }
}
