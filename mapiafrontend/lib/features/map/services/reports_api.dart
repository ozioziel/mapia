import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

class ParsedReport {
  const ParsedReport({
    required this.title,
    required this.description,
    required this.product,
    required this.alertType,
    required this.severity,
    required this.confidence,
    this.price,
    this.department,
    this.municipality,
    this.zone,
  });

  final String title;
  final String description;
  final String product;
  final AlertType alertType;
  final AlertSeverity severity;
  final double? price;
  final String? department;
  final String? municipality;
  final String? zone;
  final double confidence;

  factory ParsedReport.fromJson(Map<String, dynamic> json) {
    return ParsedReport(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      product: json['product'] as String? ?? '',
      alertType: alertTypeFromApi(json['alertType'] as String?),
      severity: severityFromApi(json['severity'] as String?),
      price: (json['price'] as num?)?.toDouble(),
      department: json['department'] as String?,
      municipality: json['municipality'] as String?,
      zone: json['zone'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.75,
    );
  }
}

class PublishReportInput {
  const PublishReportInput({
    required this.title,
    required this.alertType,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.images,
    this.description,
    this.product,
    this.department,
    this.municipality,
    this.zone,
    this.price,
    this.sourceText,
    this.confidence,
  });

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
  final double? price;
  final String? sourceText;
  final double? confidence;
  final List<XFile> images;
}

class ReportsApi {
  ReportsApi({ApiClient? client, http.Client? httpClient})
    : _client = client ?? ApiClient(),
      _http = httpClient ?? http.Client();

  static const _uploadTimeout = Duration(seconds: 30);

  final ApiClient _client;
  final http.Client _http;

  Future<ParsedReport> parseReport({
    required String text,
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{'text': text};
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;

    final json = await _client.postJson(ApiEndpoints.parseReport, payload);
    return ParsedReport.fromJson(json);
  }

  Future<String> publishReport(PublishReportInput input) async {
    final requestUri = _client.uri(ApiEndpoints.publishReport);
    final request = http.MultipartRequest('POST', requestUri);

    request.fields.addAll({
      'title': input.title,
      if (input.description != null) 'description': input.description!,
      if (input.product != null) 'product': input.product!,
      'alertType': input.alertType.apiValue,
      'severity': input.severity.apiValue,
      'latitude': input.latitude.toString(),
      'longitude': input.longitude.toString(),
      if (input.department != null) 'department': input.department!,
      if (input.municipality != null) 'municipality': input.municipality!,
      if (input.zone != null) 'zone': input.zone!,
      if (input.price != null) 'price': input.price.toString(),
      if (input.sourceText != null) 'sourceText': input.sourceText!,
      if (input.confidence != null) 'confidence': input.confidence.toString(),
    });

    for (final image in input.images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          await image.readAsBytes(),
          filename: image.name,
        ),
      );
    }

    late final http.Response response;
    try {
      final streamed = await _http.send(request).timeout(_uploadTimeout);
      response = await http.Response.fromStream(
        streamed,
      ).timeout(_uploadTimeout);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado: $requestUri', 0);
    } catch (_) {
      throw ApiException('No se pudo conectar con $requestUri', 0);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.body.isEmpty ? 'No se pudo publicar' : response.body,
        response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['id'] as String? ?? '';
  }
}
