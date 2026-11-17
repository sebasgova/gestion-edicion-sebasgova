import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../forms/movement_form.dart';
import '../forms/payment_form.dart';
import '../models/movement.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class FinanceScreen extends StatefulWidget {
  final AppState state;
  const FinanceScreen({super.key, required this.state});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String tab = 'summary'; // summary | income | expenses

  AppState get state => widget.state;

  void _openMovement(bool isIncome, [Movement? m]) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovementForm(state: state, isIncome: isIncome, initial: m)));

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Finanzas',
          subtitle: 'Saldos por cuenta, ingresos, gastos y cuentas por cobrar',
          actions: [
            if (tab != 'summary')
              FilledButton.icon(
                onPressed: () => _openMovement(tab == 'income'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(tab == 'income' ? 'Ingreso' : 'Gasto'),
              ),
          ],
        ),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'summary', label: Text('Resumen')),
            ButtonSegment(value: 'income', label: Text('Ingresos')),
            ButtonSegment(value: 'expenses', label: Text('Gastos')),
          ],
          selected: {tab},
          onSelectionChanged: (s) => setState(() => tab = s.first),
        ),
        const SizedBox(height: 16),
        Expanded(child: tab == 'summary' ? _summary() : _movements(tab == 'income')),
      ]);

  // ---------- Resumen ----------
  Widget _summary() {
    final balances = state.balances();
    final series = state.monthlySeries(6);
    final receivables = state.receivables();
    return ListView(children: [
      ResponsiveGrid(minTileWidth: 200, children: [
        KpiCard(
            label: 'Saldo total (COP)',
            value: fmtCop(state.totalBalanceCop),
            icon: Icons.account_balance_wallet_outlined),
        KpiCard(
            label: 'Ingresos del mes',
            value: fmtCop(state.incomeThisMonthCop),
            icon: Icons.south_west,
            accent: AppColors.green),
        KpiCard(
            label: 'Gastos del mes',
            value: fmtCop(state.expensesThisMonthCop),
            icon: Icons.north_east,
            accent: AppColors.red),
        KpiCard(
            label: 'Por cobrar',
            value: fmtCop(state.receivableTotalCop),
            meta: '${receivables.length} proyecto(s)',
            icon: Icons.request_quote_outlined,
            accent: AppColors.gold),
      ]),
      const SizedBox(height: 16),
      const Text('CUENTAS', style: AppTextStyles.label),
      const SizedBox(height: 8),
      ResponsiveGrid(minTileWidth: 200, children: [
        for (final a in state.data.accounts)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(a.color), shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(a.name, style: AppTextStyles.subtitle)),
                Text(a.cur, style: AppTextStyles.caption),
              ]),
              const SizedBox(height: 10),
              Text(fmtNative(balances[a.id] ?? 0, a.cur), style: AppTextStyles.title),
            ]),
          ),
      ]),
      const SizedBox(height: 16),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ingresos y gastos · últimos 6 meses', style: AppTextStyles.title),
          const SizedBox(height: 4),
          Row(children: const [
            _Legend(AppColors.green, 'Ingresos'),
            SizedBox(width: 14),
            _Legend(AppColors.red, 'Gastos'),
          ]),
          const SizedBox(height: 14),
          _chart(series),
        ]),
      ),
      const SizedBox(height: 16),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cuentas por cobrar', style: AppTextStyles.title),
          const SizedBox(height: 8),
          if (receivables.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No tienes saldos pendientes por cobrar.', style: AppTextStyles.bodyDim)),
          for (final r in receivables)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.project.title, style: AppTextStyles.subtitle),
              subtitle: Text(
                  '${r.project.client.isEmpty ? 'Sin cliente' : r.project.client} · '
                  '${r.pct == 0 ? 'Sin cobrar' : '${r.pct}% cobrado'}'
                  '${r.overdueDays > 0 ? ' · ${r.overdueDays}d de atraso' : ''}',
                  style: AppTextStyles.caption),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(fmtCop(r.pendingCop), style: AppTextStyles.subtitle),
                IconButton(
                  tooltip: 'Registrar pago',
                  icon: const Icon(Icons.add_card_outlined, color: AppColors.gold),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PaymentForm(state: state, project: r.project))),
                ),
              ]),
            ),
        ]),
      ),
      const SizedBox(height: 16),
      const ComingSoonTile(
          icon: Icons.swap_horiz,
          title: 'Transferencias entre cuentas',
          description: 'Mover dinero entre cuentas con comisiones y tasa de cambio'),
      const SizedBox(height: 8),
      const ComingSoonTile(
          icon: Icons.percent,
          title: 'Comisiones automáticas por cuenta',
          description: 'Descontar la comisión de PayPal, Payoneer, etc. al cobrar'),
    ]);
  }

  Widget _chart(List<MonthPoint> pts) {
    final maxV = pts.fold<double>(
        0, (m, p) => [m, p.income, p.expense].reduce((a, b) => a > b ? a : b));
    const h = 130.0;
    if (maxV <= 0) {
      return const SizedBox(
          height: 80, child: Center(child: Text('Sin movimientos en estos meses', style: AppTextStyles.caption)));
    }
    return SizedBox(
      height: h + 44,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final p in pts)
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(fmtCompact(p.income - p.expense),
                  style: AppTextStyles.caption.copyWith(fontSize: 10), overflow: TextOverflow.clip, maxLines: 1),
              const SizedBox(height: 4),
              SizedBox(
                height: h,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
                  _bar(p.income / maxV * h, AppColors.green),
                  const SizedBox(width: 4),
                  _bar(p.expense / maxV * h, AppColors.red),
                ]),
              ),
              const SizedBox(height: 6),
              Text(p.label, style: AppTextStyles.caption),
            ]),
          ),
      ]),
    );
  }

  Widget _bar(double height, Color color) => Container(
        width: 14,
        height: height < 2 ? 2 : height,
        decoration: BoxDecoration(
            color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      );

  // ---------- Listas ----------
  Widget _movements(bool isIncome) {
    final list = [...(isIncome ? state.data.income : state.data.expenses)]
      ..sort((a, b) => b.date.compareTo(a.date));
    if (list.isEmpty) {
      return EmptyState(
          icon: isIncome ? Icons.south_west : Icons.north_east,
          text: isIncome ? 'Sin ingresos registrados' : 'Sin gastos registrados',
          hint: 'Usa el botón de arriba para agregar uno.');
    }
    final color = isIncome ? AppColors.green : AppColors.red;
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = list[i];
        return AppCard(
          onTap: () => _openMovement(isIncome, m),
          child: Row(children: [
            Icon(isIncome ? Icons.south_west : Icons.north_east, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.concept, style: AppTextStyles.subtitle),
                Text('${state.accountName(m.account)} · ${m.date.isEmpty ? 'Sin fecha' : fmtDay(m.date)}',
                    style: AppTextStyles.caption),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${isIncome ? '+' : '-'}${fmtNative(m.amount, m.cur)}',
                  style: AppTextStyles.subtitle.copyWith(color: color)),
              if (m.cur != 'COP')
                Text('≈ ${fmtCop(state.toCop(m.amount, m.cur))}', style: AppTextStyles.caption),
            ]),
          ]),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend(this.color, this.text);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption),
      ]);
}
