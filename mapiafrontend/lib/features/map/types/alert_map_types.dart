import 'package:google_maps_flutter/google_maps_flutter.dart';

enum AlertSeverity { normal, low, medium, high }

enum AlertType {
  stockBajo,
  sobreprecio,
  bloqueo,
  retrasoProveedor,
  combustible,
  productoNoDisponible,
  otro,
}

class AlertMapItem {
  const AlertMapItem({
    required this.id,
    required this.title,
    required this.alertType,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.reportsCount,
    required this.confidence,
    required this.lastReportedAt,
    this.description,
    this.product,
    this.department,
    this.municipality,
    this.zone,
    this.avgPrice,
    this.images = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String? product;
  final AlertType alertType;
  final AlertSeverity severity;
  final double latitude;
  final double longitude;
  final String? department;
  final String? municipality;
  final String? zone;
  final int reportsCount;
  final double confidence;
  final double? avgPrice;
  final DateTime lastReportedAt;
  final List<String> images;

  LatLng get position => LatLng(latitude, longitude);

  factory AlertMapItem.fromJson(Map<String, dynamic> json) {
    return AlertMapItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Reporte ciudadano',
      description: json['description'] as String?,
      product: json['product'] as String?,
      alertType: alertTypeFromApi(json['alertType'] as String?),
      severity: severityFromApi(json['severity'] as String?),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      department: json['department'] as String?,
      municipality: json['municipality'] as String?,
      zone: json['zone'] as String?,
      reportsCount: (json['reportsCount'] as num?)?.toInt() ?? 1,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.75,
      avgPrice: (json['avgPrice'] as num?)?.toDouble(),
      lastReportedAt:
          DateTime.tryParse(json['lastReportedAt'] as String? ?? '') ??
          DateTime.now(),
      images: [
        for (final image in (json['images'] as List? ?? const []))
          if (image is String) image,
      ],
    );
  }
}

class AlertMapSummary {
  const AlertMapSummary({
    required this.totalAlerts,
    required this.highRiskAlerts,
    required this.updatedAt,
    this.mostAffectedProduct,
    this.mostAffectedDepartment,
  });

  final int totalAlerts;
  final int highRiskAlerts;
  final String? mostAffectedProduct;
  final String? mostAffectedDepartment;
  final DateTime updatedAt;

  factory AlertMapSummary.empty() => AlertMapSummary(
    totalAlerts: 0,
    highRiskAlerts: 0,
    updatedAt: DateTime.now(),
  );

  factory AlertMapSummary.fromJson(Map<String, dynamic> json) {
    return AlertMapSummary(
      totalAlerts: (json['totalAlerts'] as num?)?.toInt() ?? 0,
      highRiskAlerts: (json['highRiskAlerts'] as num?)?.toInt() ?? 0,
      mostAffectedProduct: json['mostAffectedProduct'] as String?,
      mostAffectedDepartment: json['mostAffectedDepartment'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AlertFilters {
  const AlertFilters({
    this.department,
    this.municipality,
    this.zone,
    this.product,
    this.alertType,
    this.severity,
  });

  final String? department;
  final String? municipality;
  final String? zone;
  final String? product;
  final AlertType? alertType;
  final AlertSeverity? severity;

  bool get isEmpty =>
      department == null &&
      municipality == null &&
      zone == null &&
      product == null &&
      alertType == null &&
      severity == null;

  AlertFilters copyWith({
    String? department,
    String? municipality,
    String? zone,
    String? product,
    AlertType? alertType,
    AlertSeverity? severity,
    bool clearDepartment = false,
    bool clearMunicipality = false,
    bool clearZone = false,
    bool clearProduct = false,
    bool clearAlertType = false,
    bool clearSeverity = false,
  }) {
    return AlertFilters(
      department: clearDepartment ? null : department ?? this.department,
      municipality: clearMunicipality ? null : municipality ?? this.municipality,
      zone: clearZone ? null : zone ?? this.zone,
      product: clearProduct ? null : product ?? this.product,
      alertType: clearAlertType ? null : alertType ?? this.alertType,
      severity: clearSeverity ? null : severity ?? this.severity,
    );
  }

  Map<String, String?> toQuery() => {
    'department': department,
    'municipality': municipality,
    'zone': zone,
    'product': product,
    'alertType': alertType?.apiValue,
    'severity': severity?.apiValue,
  };
}

class AlertFilterOptions {
  const AlertFilterOptions({
    this.departments = const [],
    this.municipalities = const [],
    this.zones = const [],
    this.products = const [],
    this.alertTypes = const [],
    this.severities = const [],
  });

  final List<String> departments;
  final List<String> municipalities;
  final List<String> zones;
  final List<String> products;
  final List<AlertType> alertTypes;
  final List<AlertSeverity> severities;

  factory AlertFilterOptions.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) => [
      for (final value in (json[key] as List? ?? const []))
        if (value is String) value,
    ];

    return AlertFilterOptions(
      departments: strings('departments'),
      municipalities: strings('municipalities'),
      zones: strings('zones'),
      products: strings('products'),
      alertTypes: strings('alertTypes').map(alertTypeFromApi).toList(),
      severities: strings('severities').map(severityFromApi).toList(),
    );
  }
}

extension AlertSeverityApi on AlertSeverity {
  String get apiValue => switch (this) {
    AlertSeverity.normal => 'normal',
    AlertSeverity.low => 'low',
    AlertSeverity.medium => 'medium',
    AlertSeverity.high => 'high',
  };

  String get label => switch (this) {
    AlertSeverity.normal => 'Normal',
    AlertSeverity.low => 'Riesgo bajo',
    AlertSeverity.medium => 'Riesgo medio',
    AlertSeverity.high => 'Alerta alta',
  };
}

extension AlertTypeApi on AlertType {
  String get apiValue => switch (this) {
    AlertType.stockBajo => 'stock_bajo',
    AlertType.sobreprecio => 'sobreprecio',
    AlertType.bloqueo => 'bloqueo',
    AlertType.retrasoProveedor => 'retraso_proveedor',
    AlertType.combustible => 'combustible',
    AlertType.productoNoDisponible => 'producto_no_disponible',
    AlertType.otro => 'otro',
  };

  String get label => switch (this) {
    AlertType.stockBajo => 'Stock bajo',
    AlertType.sobreprecio => 'Sobreprecio',
    AlertType.bloqueo => 'Bloqueo',
    AlertType.retrasoProveedor => 'Retraso proveedor',
    AlertType.combustible => 'Combustible',
    AlertType.productoNoDisponible => 'No disponible',
    AlertType.otro => 'Otro',
  };
}

AlertSeverity severityFromApi(String? value) {
  return AlertSeverity.values.firstWhere(
    (severity) => severity.apiValue == value,
    orElse: () => AlertSeverity.normal,
  );
}

AlertType alertTypeFromApi(String? value) {
  return AlertType.values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => AlertType.otro,
  );
}
