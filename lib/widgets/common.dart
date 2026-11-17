import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Tarjeta base con el estilo de paneles de la app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLg);
    return Material(
      color: color ?? AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Etiqueta de color (estado, prioridad, fuente...).
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.panel3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.text)),
        ]),
      );
}

/// Cabecera de sección: título, descripción y acciones.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const SectionHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          spacing: 12,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) Text(subtitle!, style: AppTextStyles.bodyDim),
            ]),
            if (actions.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? hint;
  const EmptyState({super.key, required this.icon, required this.text, this.hint});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 38, color: AppColors.textFaint),
            const SizedBox(height: 10),
            Text(text, style: AppTextStyles.bodyDim, textAlign: TextAlign.center),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(hint!, style: AppTextStyles.caption, textAlign: TextAlign.center),
            ],
          ]),
        ),
      );
}

/// Tarjeta numérica del resumen.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? meta;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.meta,
    this.accent = AppColors.blue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyDim, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 14),
          FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTextStyles.kpi)),
          if (meta != null) ...[
            const SizedBox(height: 2),
            Text(meta!, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
          ],
        ]),
      );
}

/// Barra de progreso fina.
class ThinBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  const ThinBar({super.key, required this.value, this.color = AppColors.green});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: AppColors.panel3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
}

/// Rejilla de tarjetas que se adapta al ancho disponible.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final double spacing;
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 220,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final cols = (c.maxWidth / minTileWidth).floor().clamp(1, 6);
        final w = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final child in children) SizedBox(width: w, child: child)],
        );
      });
}

// ---------- Diálogos y avisos ----------

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String okLabel = 'Eliminar',
  bool danger = true,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: Text(title, style: AppTextStyles.title),
      content: Text(body, style: AppTextStyles.bodyDim),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(okLabel),
        ),
      ],
    ),
  );
  return res == true;
}

void toast(BuildContext context, String msg) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
}

/// Función aún no implementada: se avisa de forma explícita (requisito de navegación).
void comingSoon(BuildContext context, String feature) =>
    toast(context, '$feature · disponible en el Momento 3');

/// Botón o fila marcada como "Próximamente".
class ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const ComingSoonTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: () => comingSoon(context, title),
        child: Row(children: [
          Icon(icon, color: AppColors.textFaint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyles.subtitle),
              Text(description, style: AppTextStyles.caption),
            ]),
          ),
          const Pill('Próximamente', AppColors.amber),
        ]),
      );
}
