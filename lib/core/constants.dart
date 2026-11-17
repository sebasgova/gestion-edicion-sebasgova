import 'package:flutter/material.dart';

/// Definición de una etapa (de trabajo o de ventas).
class StageDef {
  final String id;
  final String name;
  final Color color;
  final String desc;
  const StageDef(this.id, this.name, this.color, [this.desc = '']);
}

/// Catálogos fijos de la aplicación (mismos ids que la versión web,
/// para que el JSON exportado desde el HTML se pueda cargar aquí).
class AppConst {
  AppConst._();

  static const workStages = <StageDef>[
    StageDef('todo', 'Pendiente por empezar', Color(0xFF5A8BD0)),
    StageDef('edit', 'Edición', Color(0xFF9B7BD0)),
    StageDef('review', 'Revisión', Color(0xFFD9A441)),
    StageDef('changes', 'Cambios', Color(0xFFE0765A)),
    StageDef('delivered', 'Entregado', Color(0xFF4EA674)),
  ];

  static const leadStages = <StageDef>[
    StageDef('qualify', 'To be qualified', Color(0xFF5A8BD0),
        'Lead nuevo — precalificar con preguntas'),
    StageDef('discovery', 'Discovery call', Color(0xFF8B7BF0),
        'Llamada de calificación / setear al prospecto'),
    StageDef('pricing', 'Pricing', Color(0xFFE0A73F),
        'Envío de cotización / factura'),
    StageDef('won', 'Close won', Color(0xFF3FC77F),
        'Cliente cerrado con éxito'),
    StageDef('lost', 'Close lost', Color(0xFFE06A52),
        'No se cerró — registrar razón'),
  ];

  static const leadSources = ['Instagram', 'Fiverr', 'Referidos', 'ADS', 'LinkedIn'];
  static const sourceColors = <String, Color>{
    'Instagram': Color(0xFFBD6C99),
    'Fiverr': Color(0xFF009E73),
    'Referidos': Color(0xFFDD9500),
    'ADS': Color(0xFFD55E00),
    'LinkedIn': Color(0xFF3F9FD6),
  };
  static const lostReasons = ['Pricing', 'Timing', 'Eligió a otro', 'No respondió'];

  static const services = [
    'Reel (Individual)',
    'Reel (Paquete mensual)',
    'YouTube (Individual)',
    'YouTube (Paquete mensual)',
    'VSL',
    'Otro',
  ];

  static const currencies = ['COP', 'USD', 'EUR'];
  static const defaultFx = <String, double>{'COP': 1, 'USD': 3437, 'EUR': 3720};

  static const clientStatuses = <String, String>{
    'active': 'Activo',
    'lead': 'Lead',
    'paused': 'Pausa',
    'done': 'Cerrado',
  };

  static const priorities = <String, String>{
    'alta': 'Alta',
    'media': 'Media',
    'baja': 'Baja',
  };

  static const defaultEditors = ['Yo', 'Editor externo'];

  static StageDef workStage(String id) => workStages.firstWhere(
        (s) => s.id == id,
        orElse: () => StageDef(id, id, const Color(0xFF6A7382)),
      );

  static StageDef leadStage(String id) => leadStages.firstWhere(
        (s) => s.id == id,
        orElse: () => StageDef(id, id, const Color(0xFF6A7382)),
      );

  static Color sourceColor(String s) =>
      sourceColors[s] ?? const Color(0xFF7B8390);
}
