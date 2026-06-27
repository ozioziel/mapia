import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/report_candidates/domain/report_candidate.dart';

class ReportCandidatesApi {
  const ReportCandidatesApi({required this.client});

  final ApiClient client;

  Future<List<ReportCandidate>> fetchCandidates() async {
    final json = await client.getJson(ApiEndpoints.reportCandidates);
    final items = json['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(_candidateFromJson)
        .toList();
  }

  Future<ReportCandidate> createFromPost(String postId) async {
    final json = await client.postJson(
      ApiEndpoints.reportCandidateFromPost(postId),
      const {},
    );
    return _candidateFromJson(json);
  }

  Future<ReportCandidate> updateStatus(
    String id,
    ReportCandidateStatus status, {
    String? rejectionReason,
  }) async {
    final json = await client.patchJson(
      ApiEndpoints.reportCandidateStatus(id),
      {
        'status': status.apiValue,
        ...?rejectionReason == null
            ? null
            : {'rejectionReason': rejectionReason},
      },
    );
    return _candidateFromJson(json);
  }

  Future<GeneratedCitizenReport> generateReport({
    String municipality = 'Informacion no disponible',
  }) async {
    final json = await client.postJson(ApiEndpoints.generateCitizenReport, {
      'municipality': municipality,
    });
    return GeneratedCitizenReport(
      title: json['title'] as String? ?? 'Informe ciudadano',
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
      municipality: json['municipality'] as String? ?? municipality,
      candidatesCount: json['candidatesCount'] as int? ?? 0,
      body: json['body'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }
}

ReportCandidate _candidateFromJson(Map<String, dynamic> json) {
  final evidence = json['evidenceUrls'] ?? json['evidence_urls'];
  return ReportCandidate(
    id: json['id'] as String? ?? '',
    postId: json['postId'] as String? ?? json['post_id'] as String? ?? '',
    title: json['title'] as String? ?? 'Sin titulo',
    summary: json['summary'] as String? ?? 'Informacion no disponible',
    category: reportCategoryFromApi(json['category'] as String?),
    status: reportStatusFromApi(json['status'] as String?),
    priority: reportPriorityFromApi(json['priority'] as String?),
    locationText:
        json['locationText'] as String? ?? json['location_text'] as String?,
    lat: _toDouble(json['lat']),
    lng: _toDouble(json['lng']),
    evidenceUrls: evidence is List ? evidence.whereType<String>().toList() : [],
    citizenSupportCount:
        json['citizenSupportCount'] as int? ??
        json['citizen_support_count'] as int? ??
        0,
    commentsCount:
        json['commentsCount'] as int? ?? json['comments_count'] as int? ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    authorReputationScore:
        json['authorReputationScore'] as int? ??
        json['author_reputation_score'] as int?,
    authorPostsCount:
        json['authorPostsCount'] as int? ??
        json['author_posts_count'] as int? ??
        0,
    aiSummary: json['aiSummary'] as String? ?? json['ai_summary'] as String?,
    suggestedSolution:
        json['suggestedSolution'] as String? ??
        json['suggested_solution'] as String?,
    rejectionReason:
        json['rejectionReason'] as String? ??
        json['rejection_reason'] as String?,
  );
}

double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
