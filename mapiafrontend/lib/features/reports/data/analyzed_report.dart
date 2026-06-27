/// Modelo del Paso 1 (analizar): aviso clasificado + esquema de campos dinámico.
/// Coincide con `AnalyzedReport` del backend (`POST /reports/analyze`).
class AnalyzedField {
  const AnalyzedField({
    required this.key,
    required this.label,
    required this.type,
    required this.value,
    required this.required,
    required this.source,
    this.hint,
    this.options = const [],
  });

  final String key;
  final String label;
  final String type; // text|textarea|number|date|time|select|bool
  final String? value;
  final bool required;
  final String source; // 'ai' | 'empty'
  final String? hint;
  final List<String> options;

  bool get detectedByAi => source == 'ai' && (value?.isNotEmpty ?? false);

  factory AnalyzedField.fromJson(Map<String, dynamic> json) {
    return AnalyzedField(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      value: (json['value'] as String?)?.trim().isEmpty ?? true
          ? null
          : json['value'] as String?,
      required: json['required'] as bool? ?? false,
      source: json['source'] as String? ?? 'empty',
      hint: json['hint'] as String?,
      options: [
        for (final o in (json['options'] as List? ?? const []))
          if (o is String) o,
      ],
    );
  }
}

class AnalyzedReport {
  const AnalyzedReport({
    required this.category,
    required this.categoryLabel,
    required this.group,
    required this.title,
    required this.description,
    required this.summary,
    required this.icon,
    required this.color,
    required this.riskLevel,
    required this.confidence,
    required this.fields,
    this.zone,
    this.latitude,
    this.longitude,
    this.usedAi = false,
  });

  final String category;
  final String categoryLabel;
  final String group;
  final String title;
  final String description;
  final String summary;
  final String icon;
  final String color; // hex #RRGGBB
  final String riskLevel; // info|low|medium|high|critical
  final double confidence;
  final String? zone;
  final double? latitude;
  final double? longitude;
  final List<AnalyzedField> fields;
  final bool usedAi;

  factory AnalyzedReport.fromJson(Map<String, dynamic> json) {
    return AnalyzedReport(
      category: json['category'] as String? ?? 'otro',
      categoryLabel: json['categoryLabel'] as String? ?? 'Otro',
      group: json['group'] as String? ?? 'otro',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      icon: json['icon'] as String? ?? 'place',
      color: json['color'] as String? ?? '#64748B',
      riskLevel: json['riskLevel'] as String? ?? 'info',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      zone: json['zone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      usedAi: json['usedAi'] as bool? ?? false,
      fields: [
        for (final f in (json['fields'] as List? ?? const []))
          if (f is Map<String, dynamic>) AnalyzedField.fromJson(f),
      ],
    );
  }
}

/// Catálogo de categorías para el selector editable (espejo del backend).
const List<({String code, String label})> kReportCategories = [
  (code: 'fiesta', label: 'Fiesta'),
  (code: 'celebracion', label: 'Celebración'),
  (code: 'evento_comunitario', label: 'Evento comunitario'),
  (code: 'concierto_libre', label: 'Concierto libre'),
  (code: 'feria', label: 'Feria'),
  (code: 'entrada_folklorica', label: 'Entrada folklórica'),
  (code: 'cultura', label: 'Cultura'),
  (code: 'deporte', label: 'Deporte'),
  (code: 'descuento', label: 'Descuento'),
  (code: 'promocion', label: 'Promoción'),
  (code: 'bloqueo', label: 'Bloqueo'),
  (code: 'marcha', label: 'Marcha'),
  (code: 'transporte', label: 'Transporte'),
  (code: 'incendio', label: 'Incendio'),
  (code: 'accidente', label: 'Accidente'),
  (code: 'emergencia', label: 'Emergencia'),
  (code: 'seguridad', label: 'Seguridad'),
  (code: 'salud', label: 'Salud'),
  (code: 'abastecimiento', label: 'Abastecimiento'),
  (code: 'combustible', label: 'Combustible'),
  (code: 'servicio_publico', label: 'Servicio público'),
  (code: 'otro', label: 'Otro'),
];
