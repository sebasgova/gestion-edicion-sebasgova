import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/feature_inventory.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final usd = TextEditingController(text: _fx('USD'));
  late final eur = TextEditingController(text: _fx('EUR'));
  late final editors = TextEditingController(text: widget.state.data.editors.join(', '));
  late final capacity = TextEditingController(text: '${widget.state.data.capacity}');

  AppState get state => widget.state;

  String _fx(String cur) {
    final n = state.fxOf(cur);
    return n == n.roundToDouble() ? n.round().toString() : n.toString();
  }

  @override
  void dispose() {
    for (final c in [usd, eur, editors, capacity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveFx() async {
    final u = double.tryParse(usd.text.replaceAll(',', '.')) ?? 0;
    final e = double.tryParse(eur.text.replaceAll(',', '.')) ?? 0;
    if (u <= 0 || e <= 0) {
      toast(context, 'Escribe tasas válidas (mayores que cero)');
      return;
    }
    await state.setFx(u, e);
    if (mounted) toast(context, 'Tasas de cambio guardadas');
  }

  Future<void> _saveWork() async {
    await state.setEditors(editors.text.split(','));
    await state.setCapacity(int.tryParse(capacity.text) ?? 5);
    if (mounted) toast(context, 'Ajustes de trabajo guardados');
  }

  Future<void> _export() async {
    final json = state.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    toast(context, 'Respaldo copiado al portapapeles (${json.length} caracteres)');
  }

  Future<void> _import() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('Cargar respaldo', style: AppTextStyles.title),
        content: SizedBox(
          width: 520,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
                'Pega el JSON exportado desde esta app o desde la versión web. '
                'Reemplazará los datos actuales.',
                style: AppTextStyles.bodyDim),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(hintText: '{ "clients": [...], "projects": [...] }'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data?.text != null) controller.text = data!.text!;
            },
            child: const Text('Pegar'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Cargar')),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || raw.trim().isEmpty) return;
    try {
      await state.importJson(raw);
      if (!mounted) return;
      usd.text = _fx('USD');
      eur.text = _fx('EUR');
      editors.text = state.data.editors.join(', ');
      capacity.text = '${state.data.capacity}';
      toast(context, 'Respaldo cargado correctamente');
    } on FormatException catch (e) {
      if (mounted) toast(context, 'No se pudo cargar: ${e.message}');
    }
  }

  Future<void> _demo() async {
    final ok = await confirmDialog(context,
        title: 'Cargar datos de ejemplo',
        body: 'Reemplazará los datos actuales con clientes, proyectos, pagos y tareas de ejemplo.',
        okLabel: 'Cargar',
        danger: false);
    if (!ok) return;
    await state.loadDemo();
    if (mounted) toast(context, 'Datos de ejemplo cargados');
  }

  Future<void> _wipe() async {
    final ok = await confirmDialog(context,
        title: 'Borrar todos los datos',
        body: 'Se eliminarán clientes, proyectos, pipeline, tareas y finanzas. No se puede deshacer.',
        okLabel: 'Borrar todo');
    if (!ok) return;
    await state.clearAll();
    if (mounted) toast(context, 'Datos borrados');
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => ListView(children: [
        const SectionHeader(title: 'Ajustes', subtitle: 'Tasas, respaldo y estado del proyecto'),
        _section('Tasas de cambio (a COP)', [
          Row(children: [
            Expanded(
                child: TextField(
                    controller: usd,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '1 USD =', prefixText: r'$ '))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: eur,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '1 EUR =', prefixText: r'$ '))),
          ]),
          const SizedBox(height: 12),
          Align(
              alignment: Alignment.centerRight,
              child: FilledButton(onPressed: _saveFx, child: const Text('Guardar tasas'))),
        ]),
        _section('Trabajo', [
          TextField(
              controller: editors,
              decoration: const InputDecoration(
                  labelText: 'Editores (separados por coma)', hintText: 'Yo, Editor externo')),
          const SizedBox(height: 12),
          TextField(
              controller: capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacidad de proyectos simultáneos')),
          const SizedBox(height: 12),
          Align(
              alignment: Alignment.centerRight,
              child: FilledButton(onPressed: _saveWork, child: const Text('Guardar'))),
        ]),
        _section('Respaldo y datos', [
          const Text(
              'Los datos se guardan en este dispositivo o navegador. El respaldo usa el mismo formato JSON '
              'que la versión web, así puedes pasar tu información de una a otra.',
              style: AppTextStyles.bodyDim),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            OutlinedButton.icon(
                onPressed: _export, icon: const Icon(Icons.download_outlined, size: 18), label: const Text('Exportar (copiar JSON)')),
            OutlinedButton.icon(
                onPressed: _import, icon: const Icon(Icons.upload_outlined, size: 18), label: const Text('Cargar JSON')),
            OutlinedButton.icon(
                onPressed: _demo, icon: const Icon(Icons.auto_awesome_outlined, size: 18), label: const Text('Datos de ejemplo')),
            OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                onPressed: _wipe,
                icon: const Icon(Icons.delete_forever_outlined, size: 18),
                label: const Text('Borrar todo')),
          ]),
        ]),
        const ComingSoonTile(
            icon: Icons.tune,
            title: 'Etapas y cuentas personalizadas',
            description: 'Crear, ordenar y colorear etapas y cuentas bancarias'),
        const SizedBox(height: 14),
        _progressCard(),
      ]);

  Widget _progressCard() {
    String label(FeatureStatus s) =>
        s == FeatureStatus.complete ? 'Completa' : s == FeatureStatus.inProgress ? 'En desarrollo' : 'Pendiente';
    Color color(FeatureStatus s) =>
        s == FeatureStatus.complete ? AppColors.green : s == FeatureStatus.inProgress ? AppColors.amber : AppColors.textFaint;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Estado del proyecto · Momento 2', style: AppTextStyles.title)),
          Text('$progressPercent%', style: AppTextStyles.title.copyWith(color: AppColors.gold)),
        ]),
        const SizedBox(height: 4),
        Text('$completeCount de ${featureInventory.length} funcionalidades completas',
            style: AppTextStyles.caption),
        const SizedBox(height: 10),
        ThinBar(value: completeCount / featureInventory.length, color: AppColors.gold),
        const SizedBox(height: 12),
        for (final f in featureInventory)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.name, style: AppTextStyles.body),
                  Text(f.evidence, style: AppTextStyles.caption),
                ]),
              ),
              const SizedBox(width: 10),
              Pill(label(f.status), color(f.status)),
            ]),
          ),
      ]),
    );
  }
}
