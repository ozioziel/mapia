import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/report_candidates/data/mock_report_candidates.dart';
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
  bool usingMockData = false;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final loaded = await api.fetchCandidates();
      candidates = loaded.isEmpty ? MockReportCandidates.items : loaded;
      usingMockData = loaded.isEmpty;
    } catch (e) {
      candidates = MockReportCandidates.items;
      usingMockData = true;
      error = 'Mostrando datos de prueba. Backend no disponible: $e';
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

    if (usingMockData) return;
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
      if (usingMockData) {
        generatedReport = _generateMockReport();
      } else {
        generatedReport = await api.generateReport(municipality: 'Bolivia');
      }
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

  GeneratedCitizenReport _generateMockReport() {
    final approved = candidates
        .where(
          (item) => item.status == ReportCandidateStatus.aprobadoParaInforme,
        )
        .toList();
    final lines = [
      'Informe ciudadano de problematicas urbanas reportadas en MAPIA',
      '',
      '1. Fecha del informe',
      DateTime.now().toIso8601String().split('T').first,
      '',
      '2. Ciudad o municipio',
      'Bolivia',
      '',
      '3. Resumen ejecutivo',
      'Este borrador consolida ${approved.length} caso(s) aprobados para revision formal.',
      '',
      '4. Lista de problemas reportados',
      for (final item in approved) ...[
        '- ${item.title}',
        '  Categoria: ${item.category.label}',
        '  Ubicacion: ${item.locationText ?? "Informacion no disponible"}',
        '  Prioridad: ${item.priority.label}',
        '  Apoyo ciudadano: ${item.citizenSupportCount} apoyo(s), ${item.commentsCount} comentario(s)',
        '  Posible solucion sugerida: ${item.suggestedSolution ?? "Informacion no disponible"}',
      ],
      '',
      '10. Conclusion formal',
      'Este documento debe ser revisado por una persona administradora antes de cualquier envio externo.',
    ];
    return GeneratedCitizenReport(
      title: 'Informe ciudadano de problematicas urbanas reportadas en MAPIA',
      generatedAt: DateTime.now(),
      municipality: 'Bolivia',
      candidatesCount: approved.length,
      body: lines.join('\n'),
      note: 'Borrador de prueba. No fue enviado automaticamente.',
    );
  }
}
