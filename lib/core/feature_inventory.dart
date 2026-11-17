/// Inventario de funcionalidades del proyecto (se muestra en Ajustes y se
/// replica en el README). Mantener ambos sincronizados.
enum FeatureStatus { complete, inProgress, pending }

class Feature {
  final String name;
  final FeatureStatus status;
  final String evidence;
  const Feature(this.name, this.status, this.evidence);
}

const featureInventory = <Feature>[
  Feature('Gestión de clientes (crear, listar, buscar, editar, eliminar)', FeatureStatus.complete,
      'Pantalla Clientes'),
  Feature('Gestión de proyectos con tablero por etapa y lista', FeatureStatus.complete,
      'Pantalla Proyectos y ficha del proyecto'),
  Feature('Pipeline de ventas (mover etapas, motivo de pérdida, convertir en cliente)',
      FeatureStatus.complete, 'Pantalla Pipeline'),
  Feature('Tareas con prioridad, fecha, filtro y completar', FeatureStatus.complete,
      'Pantalla Pendientes'),
  Feature('Registro de pagos por proyecto y cuentas por cobrar', FeatureStatus.complete,
      'Ficha del proyecto y Finanzas'),
  Feature('Ingresos, gastos y saldo por cuenta (multimoneda COP/USD/EUR)', FeatureStatus.complete,
      'Pantalla Finanzas'),
  Feature('Agenda de entregas (proyectos + tareas)', FeatureStatus.complete, 'Pantalla Entregas'),
  Feature('Guardado local + exportar/cargar JSON compatible con la web', FeatureStatus.complete,
      'Pantalla Ajustes'),
  Feature('Gráfica de finanzas (tendencia mensual)', FeatureStatus.inProgress,
      'Finanzas > Resumen (falta dona por servicio)'),
  Feature('Transferencias y comisiones por cuenta', FeatureStatus.pending,
      'Tarjeta "Próximamente" en Finanzas'),
  Feature('Videos y lotes de proyectos mensuales', FeatureStatus.pending,
      'Tarjeta "Próximamente" en la ficha del proyecto'),
  Feature('Editar etapas y cuentas personalizadas', FeatureStatus.pending,
      'Tarjeta "Próximamente" en Ajustes'),
  Feature('Arrastrar y soltar en tableros', FeatureStatus.pending, 'Hoy se usa el menú "Mover a..."'),
  Feature('Calendario mensual', FeatureStatus.pending, 'Tarjeta "Próximamente" en Entregas'),
];

int get completeCount => featureInventory.where((f) => f.status == FeatureStatus.complete).length;

/// Porcentaje de funcionalidades completas sobre el alcance planificado.
int get progressPercent => (completeCount / featureInventory.length * 100).round();
