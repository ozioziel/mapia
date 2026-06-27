import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/report_candidates/data/report_candidates_api.dart';
import 'package:mapiafrontend/features/report_candidates/domain/report_candidate.dart';

class ReportCandidatesProvider extends ChangeNotifier {
  ReportCandidatesProvider({required this.api});

  final ReportCandidatesApi api;

  List<ReportCandidate> candidates = const [];
  GeneratedCitizenReport? generatedReport;
  bool isLoading = false;
  bool isGenerating = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      candidates = await api.fetchCandidates();
    } catch (e) {
      candidates = const [];
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    String id,
    ReportCandidateStatus status, {
    String? rejectionReason,
  }) async {
    final current = _find(id);
    if (current == null) return;
    _replace(
      current.copyWith(status: status, rejectionReason: rejectionReason),
    );

    try {
      final updated = await api.updateStatus(
        id,
        status,
        rejectionReason: rejectionReason,
      );
      _replace(updated);
    } catch (e) {
      error = e.toString();
      _replace(current);
      notifyListeners();
    }
  }

  Future<void> generateReport() async {
    isGenerating = true;
    generatedReport = null;
    error = null;
    notifyListeners();
    try {
      generatedReport = await api.generateReport(municipality: 'Bolivia');
    } catch (e) {
      error = e.toString();
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  ReportCandidate? _find(String id) {
    for (final candidate in candidates) {
      if (candidate.id == id) return candidate;
    }
    return null;
  }

  void _replace(ReportCandidate updated) {
    candidates = [
      for (final candidate in candidates)
        if (candidate.id == updated.id) updated else candidate,
    ];
    notifyListeners();
  }
}
