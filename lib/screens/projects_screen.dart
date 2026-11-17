import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/project_form.dart';
import '../models/project.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final AppState state;
  const ProjectsScreen({super.key, required this.state});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String search = '';
  String stageFilter = 'all';
  bool board = true;

  AppState get state => widget.state;

  void _open(Project p) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProjectDetailScreen(state: state, projectId: p.id)));

  void _new() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ProjectForm(state: state)));

  @override
  Widget build(BuildContext context) {
    final q = search.toLowerCase();
    final items = state.data.projects
        .where((p) =>
            (stageFilter == 'all' || p.stage == stageFilter) &&
            ('${p.title} ${p.client} ${p.service}').toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => (a.due.isEmpty ? '9999' : a.due).compareTo(b.due.isEmpty ? '9999' : b.due));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Proyectos',
        subtitle: '${state.data.projects.length} proyecto(s) · tablero por etapa de producción',
        actions: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, icon: Icon(Icons.view_kanban_outlined, size: 18), label: Text('Tablero')),
              ButtonSegment(value: false, icon: Icon(Icons.view_list_outlined, size: 18), label: Text('Lista')),
            ],
            selected: {board},
            onSelectionChanged: (s) => setState(() => board = s.first),
          ),
          FilledButton.icon(
              onPressed: _new, icon: const Icon(Icons.add, size: 18), label: const Text('Proyecto')),
        ],
      ),
      Wrap(spacing: 12, runSpacing: 10, children: [
        SizedBox(
          width: 300,
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Buscar por título, cliente o servicio'),
          ),
        ),
        if (!board)
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              value: stageFilter,
              isExpanded: true,
              dropdownColor: AppColors.panel2,
              items: [
                const DropdownMenuItem(value: 'all', child: Text('Todas las etapas')),
                for (final s in AppConst.workStages) DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => stageFilter = v ?? 'all'),
            ),
          ),
      ]),
      const SizedBox(height: 14),
      Expanded(
        child: items.isEmpty
            ? EmptyState(
                icon: Icons.movie_creation_outlined,
                text: state.data.projects.isEmpty
                    ? 'Aún no tienes proyectos'
                    : 'Ningún proyecto coincide con la búsqueda',
                hint: state.data.projects.isEmpty ? 'Crea el primero con el botón "Proyecto".' : null)
            : board
                ? _boardView(items)
                : _listView(items),
      ),
    ]);
  }

  Widget _listView(List<Project> items) => ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _projectCard(items[i], showStage: true),
      );

  Widget _boardView(List<Project> items) => ListView(scrollDirection: Axis.horizontal, children: [
        for (final s in AppConst.workStages) _column(s, items.where((p) => p.stage == s.id).toList()),
      ]);

  Widget _column(StageDef s, List<Project> items) => Container(
        width: 275,
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
              Container(width: 9, height: 9, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(s.name, style: AppTextStyles.subtitle)),
              Text('${items.length}', style: AppTextStyles.bodyDim),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Vacío', style: AppTextStyles.caption))
                : ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      for (final p in items)
                        Padding(padding: const EdgeInsets.only(bottom: 8), child: _projectCard(p)),
                    ],
                  ),
          ),
        ]),
      );

  Widget _projectCard(Project p, {bool showStage = false}) {
    final dl = daysLeft(p.due);
    final dueColor = dl == null
        ? AppColors.textFaint
        : dl < 0
            ? AppColors.red
            : dl <= 3
                ? AppColors.amber
                : AppColors.textDim;
    final delivered = p.stage == 'delivered';
    final paidPct = p.price <= 0
        ? 0.0
        : (state.projectPaidCop(p) / state.toCop(p.price, p.cur)).clamp(0.0, 1.0);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      onTap: () => _open(p),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title, style: AppTextStyles.subtitle),
            if (p.client.isNotEmpty) Text(p.client, style: AppTextStyles.bodyDim),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (showStage) Pill(AppConst.workStage(p.stage).name, AppConst.workStage(p.stage).color),
              if (p.due.isNotEmpty && !delivered)
                Text('${fmtDay(p.due)} · ${dueLabel(dl)}',
                    style: AppTextStyles.caption.copyWith(color: dueColor)),
              if (p.price > 0) Text(fmtNative(p.price, p.cur), style: AppTextStyles.caption),
            ]),
            if (p.price > 0) ...[
              const SizedBox(height: 8),
              ThinBar(value: paidPct, color: paidPct >= 1 ? AppColors.green : AppColors.gold),
            ],
          ]),
        ),
        PopupMenuButton<String>(
          tooltip: 'Mover a...',
          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textDim),
          onSelected: (s) => state.moveProject(p.id, s),
          itemBuilder: (_) => [
            for (final s in AppConst.workStages)
              if (s.id != p.stage) PopupMenuItem(value: s.id, child: Text('Mover a ${s.name}')),
          ],
        ),
      ]),
    );
  }
}
