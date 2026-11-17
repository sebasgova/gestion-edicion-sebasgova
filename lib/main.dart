import 'package:flutter/material.dart';
import 'screens/clients_screen.dart';
import 'screens/deliveries_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/pipeline_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SebasgovaApp());
}

class SebasgovaApp extends StatefulWidget {
  const SebasgovaApp({super.key});

  @override
  State<SebasgovaApp> createState() => _SebasgovaAppState();
}

class _SebasgovaAppState extends State<SebasgovaApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    state.load();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sebasgova Edición',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: AnimatedBuilder(
          animation: state,
          builder: (context, _) => state.ready
              ? Workspace(state: state)
              : const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
}

/// Contenedor principal: menú lateral (escritorio) o cajón (móvil).
class Workspace extends StatefulWidget {
  final AppState state;
  const Workspace({super.key, required this.state});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  int current = 0;

  static const names = [
    'Resumen', 'Pipeline', 'Proyectos', 'Clientes',
    'Pendientes', 'Finanzas', 'Entregas', 'Ajustes',
  ];
  static const icons = [
    Icons.dashboard_outlined, Icons.account_tree_outlined, Icons.movie_creation_outlined,
    Icons.people_outline, Icons.task_alt, Icons.payments_outlined,
    Icons.calendar_month_outlined, Icons.settings_outlined,
  ];

  AppState get state => widget.state;

  void navigate(int index) => setState(() => current = index);

  Widget content() {
    switch (current) {
      case 0:
        return OverviewScreen(state: state, navigate: navigate);
      case 1:
        return PipelineScreen(state: state);
      case 2:
        return ProjectsScreen(state: state);
      case 3:
        return ClientsScreen(state: state);
      case 4:
        return TasksScreen(state: state);
      case 5:
        return FinanceScreen(state: state);
      case 6:
        return DeliveriesScreen(state: state);
      default:
        return SettingsScreen(state: state);
    }
  }

  Widget menu(bool drawer) => Container(
        width: drawer ? null : 224,
        color: AppColors.raised,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          children: [
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.panel2,
                child: Text('S', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
              ),
              title: Text('Sebasgova', style: AppTextStyles.subtitle),
              subtitle: Text('EDICIÓN',
                  style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.gold)),
            ),
            const Divider(height: 24),
            for (var i = 0; i < names.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  dense: true,
                  shape: const StadiumBorder(),
                  selected: current == i,
                  selectedTileColor: AppColors.text,
                  selectedColor: AppColors.bg,
                  leading: Icon(icons[i], size: 21, color: current == i ? AppColors.bg : AppColors.textDim),
                  title: Text(names[i], style: const TextStyle(fontSize: 13)),
                  onTap: () {
                    navigate(i);
                    if (drawer) Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        return Scaffold(
          appBar: wide ? null : AppBar(title: Text(names[current])),
          drawer: wide ? null : Drawer(backgroundColor: AppColors.raised, child: SafeArea(child: menu(true))),
          body: Row(children: [
            if (wide) menu(false),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(wide ? 28 : 14),
                child: content(),
              ),
            ),
          ]),
        );
      });
}
