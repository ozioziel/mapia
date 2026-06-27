import 'package:mapiafrontend/features/reports/data/analyzed_report.dart';

class OptionalCategoryConfig {
  const OptionalCategoryConfig({
    required this.code,
    required this.label,
    required this.group,
    required this.icon,
    required this.color,
    required this.riskLevel,
    required this.fields,
  });

  final String code;
  final String label;
  final String group;
  final String icon;
  final String color;
  final String riskLevel;
  final List<AnalyzedField> fields;
}

OptionalCategoryConfig optionalConfigForCategory(String code) {
  return _configs[code] ?? _configs['otro']!;
}

List<AnalyzedField> optionalFieldsForCategory({
  required String category,
  AnalyzedReport? analyzed,
}) {
  if (analyzed != null &&
      analyzed.category == category &&
      analyzed.fields.isNotEmpty) {
    return analyzed.fields;
  }
  return optionalConfigForCategory(category).fields;
}

AnalyzedField _field(
  String key,
  String label,
  String type, {
  String? hint,
  List<String> options = const [],
}) {
  return AnalyzedField(
    key: key,
    label: label,
    type: type,
    value: null,
    required: false,
    source: 'empty',
    hint: hint,
    options: options,
  );
}

final _eventFields = [
  _field('date', 'Fecha', 'date'),
  _field('startTime', 'Hora de inicio', 'time'),
  _field('endTime', 'Hora de fin', 'time'),
  _field('price', 'Costo o entrada', 'number', hint: '0 si es gratis'),
  _field('organizer', 'Organizador', 'text'),
  _field(
    'ticketContact',
    'Contacto',
    'text',
    hint: 'WhatsApp, teléfono o lugar',
  ),
];

final _dealFields = [
  _field('placeName', 'Nombre del lugar', 'text'),
  _field('productOrService', 'Producto o servicio', 'text'),
  _field('newPrice', 'Precio actual', 'number'),
  _field('validUntil', 'Vigencia', 'text'),
  _field('contact', 'Contacto', 'text'),
];

final _alertFields = [
  _field(
    'dangerLevel',
    'Nivel de urgencia',
    'select',
    options: ['bajo', 'medio', 'alto', 'crítico'],
  ),
  _field('exactLocation', 'Ubicación exacta', 'text'),
  _field('recommendation', 'Recomendación', 'textarea'),
];

final _routeFields = [
  _field('route', 'Ruta o línea', 'text'),
  _field(
    'affectationType',
    'Afectación',
    'select',
    options: ['parcial', 'total'],
  ),
  _field('approxTime', 'Hora aproximada', 'time'),
  _field('recommendation', 'Recomendación', 'textarea'),
];

final _serviceFields = [
  _field(
    'serviceType',
    'Tipo de servicio',
    'select',
    options: ['agua', 'luz', 'gas', 'internet', 'otro'],
  ),
  _field('affectation', 'Afectación', 'text'),
  _field('estimatedRestore', 'Restablecimiento estimado', 'text'),
  _field('recommendation', 'Recomendación', 'textarea'),
];

final Map<String, OptionalCategoryConfig> _configs = {
  for (final code in [
    'fiesta',
    'celebracion',
    'evento_comunitario',
    'concierto_libre',
    'feria',
    'entrada_folklorica',
    'cultura',
    'deporte',
  ])
    code: OptionalCategoryConfig(
      code: code,
      label: _labelFor(code),
      group: 'evento',
      icon: 'event',
      color: '#8B5CF6',
      riskLevel: 'info',
      fields: _eventFields,
    ),
  'descuento': OptionalCategoryConfig(
    code: 'descuento',
    label: 'Descuento',
    group: 'comercio',
    icon: 'sell',
    color: '#22C55E',
    riskLevel: 'info',
    fields: _dealFields,
  ),
  'promocion': OptionalCategoryConfig(
    code: 'promocion',
    label: 'Promoción',
    group: 'comercio',
    icon: 'local_offer',
    color: '#16A34A',
    riskLevel: 'info',
    fields: _dealFields,
  ),
  'bloqueo': OptionalCategoryConfig(
    code: 'bloqueo',
    label: 'Bloqueo',
    group: 'conflicto',
    icon: 'block',
    color: '#F97316',
    riskLevel: 'high',
    fields: _alertFields,
  ),
  'marcha': OptionalCategoryConfig(
    code: 'marcha',
    label: 'Marcha',
    group: 'conflicto',
    icon: 'campaign',
    color: '#FB923C',
    riskLevel: 'medium',
    fields: _alertFields,
  ),
  'transporte': OptionalCategoryConfig(
    code: 'transporte',
    label: 'Transporte',
    group: 'movilidad',
    icon: 'directions_bus',
    color: '#0EA5E9',
    riskLevel: 'medium',
    fields: _routeFields,
  ),
  for (final code in [
    'incendio',
    'accidente',
    'emergencia',
    'seguridad',
    'salud',
  ])
    code: OptionalCategoryConfig(
      code: code,
      label: _labelFor(code),
      group: 'emergencia',
      icon: 'warning',
      color: '#EF4444',
      riskLevel: code == 'salud' ? 'medium' : 'high',
      fields: _alertFields,
    ),
  for (final code in ['abastecimiento', 'combustible'])
    code: OptionalCategoryConfig(
      code: code,
      label: _labelFor(code),
      group: 'abastecimiento',
      icon: 'inventory_2',
      color: '#CA8A04',
      riskLevel: code == 'combustible' ? 'high' : 'medium',
      fields: _dealFields,
    ),
  'servicio_publico': OptionalCategoryConfig(
    code: 'servicio_publico',
    label: 'Servicio público',
    group: 'servicio',
    icon: 'water_drop',
    color: '#0284C7',
    riskLevel: 'medium',
    fields: _serviceFields,
  ),
  'otro': const OptionalCategoryConfig(
    code: 'otro',
    label: 'Otro',
    group: 'otro',
    icon: 'place',
    color: '#64748B',
    riskLevel: 'info',
    fields: [],
  ),
};

String _labelFor(String code) {
  for (final category in kReportCategories) {
    if (category.code == code) return category.label;
  }
  return 'Otro';
}
