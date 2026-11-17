import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../forms/client_form.dart';
import '../models/client.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

class ClientsScreen extends StatefulWidget {
  final AppState state;
  const ClientsScreen({super.key, required this.state});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String search = '';
  String status = 'all';

  AppState get state => widget.state;

  void _open([Client? c]) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ClientForm(state: state, initial: c)));

  Color _statusColor(String s) {
    switch (s) {
      case 'active':
        return AppColors.green;
      case 'lead':
        return AppColors.blue;
      case 'paused':
        return AppColors.amber;
      default:
        return AppColors.textFaint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = search.toLowerCase();
    final items = state.data.clients
        .where((c) =>
            (status == 'all' || c.status == status) &&
            ('${c.name} ${c.contact} ${c.type}').toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Clientes',
        subtitle: '${state.data.clients.length} cliente(s) en tu cartera',
        actions: [
          FilledButton.icon(
              onPressed: () => _open(), icon: const Icon(Icons.add, size: 18), label: const Text('Cliente')),
        ],
      ),
      Wrap(spacing: 12, runSpacing: 10, children: [
        SizedBox(
          width: 300,
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Buscar por nombre, contacto o servicio'),
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: status,
            isExpanded: true,
            dropdownColor: AppColors.panel2,
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Todos los estados')),
              for (final e in AppConst.clientStatuses.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => status = v ?? 'all'),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      Expanded(
        child: items.isEmpty
            ? EmptyState(
                icon: Icons.people_outline,
                text: state.data.clients.isEmpty ? 'Aún no tienes clientes' : 'Sin resultados',
                hint: state.data.clients.isEmpty ? 'Crea el primero con el botón "Cliente".' : null)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _card(items[i]),
              ),
      ),
    ]);
  }

  Widget _card(Client c) {
    final projects = state.projectsOfClient(c.name);
    final active = projects.where((p) => p.stage != 'delivered').length;
    final pending = projects.fold(0.0, (s, p) {
      final total = state.toCop(p.price, p.cur);
      final paid = state.projectPaidCop(p);
      return s + (total > paid ? total - paid : 0.0);
    });
    return AppCard(
      onTap: () => _open(c),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.blueSoft,
          child: Text(initials(c.name), style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: AppTextStyles.subtitle),
            Text([c.type, c.contact, c.rate].where((e) => e.isNotEmpty).join(' · '),
                style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, children: [
              Pill(AppConst.clientStatuses[c.status] ?? c.status, _statusColor(c.status)),
              Text('${projects.length} proyecto(s) · $active activo(s)', style: AppTextStyles.caption),
              if (pending > 0)
                Text('Por cobrar ${fmtCop(pending)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
            ]),
          ]),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textFaint),
      ]),
    );
  }
}
