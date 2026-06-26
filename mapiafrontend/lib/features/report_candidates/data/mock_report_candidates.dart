import 'package:mapiafrontend/features/report_candidates/domain/report_candidate.dart';

class MockReportCandidates {
  static final List<ReportCandidate> items = [
    ReportCandidate(
      id: 'candidate-bache-sopocachi',
      postId: 'mock-bache-sopocachi',
      title: 'Bache grande en zona Sopocachi',
      summary:
          'Vecinos reportan un bache de gran tamano que dificulta el paso vehicular y peatonal.',
      category: ReportCandidateCategory.bache,
      status: ReportCandidateStatus.aprobadoParaInforme,
      priority: ReportCandidatePriority.alta,
      locationText: 'Sopocachi, La Paz',
      lat: -16.5102,
      lng: -68.1372,
      citizenSupportCount: 58,
      commentsCount: 17,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      suggestedSolution:
          'Realizar inspeccion vial, senalizar el area y programar reparacion del pavimento.',
    ),
    ReportCandidate(
      id: 'candidate-agua-cochabamba',
      postId: 'mock-agua-cochabamba',
      title: 'Corte de agua reportado en Cochabamba',
      summary:
          'Familias de la zona informan interrupcion del servicio de agua desde la manana.',
      category: ReportCandidateCategory.corteServicio,
      status: ReportCandidateStatus.pendienteRevision,
      priority: ReportCandidatePriority.alta,
      locationText: 'Cala Cala, Cochabamba',
      lat: -17.3721,
      lng: -66.1653,
      citizenSupportCount: 44,
      commentsCount: 13,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      suggestedSolution:
          'Coordinar verificacion tecnica y comunicar horario estimado de reposicion.',
    ),
    ReportCandidate(
      id: 'candidate-bloqueo-el-alto',
      postId: 'mock-bloqueo-el-alto',
      title: 'Bloqueo vehicular en El Alto',
      summary:
          'Se reporta congestion por bloqueo en una via principal con desvio de transporte publico.',
      category: ReportCandidateCategory.bloqueo,
      status: ReportCandidateStatus.aprobadoParaInforme,
      priority: ReportCandidatePriority.urgente,
      locationText: 'Ceja, El Alto',
      lat: -16.5005,
      lng: -68.1651,
      citizenSupportCount: 71,
      commentsCount: 25,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      suggestedSolution:
          'Verificar la situacion en via publica y coordinar rutas alternas temporales.',
    ),
    ReportCandidate(
      id: 'candidate-basura-scz',
      postId: 'mock-basura-scz',
      title: 'Basura acumulada en una avenida de Santa Cruz',
      summary:
          'Usuarios reportan acumulacion de residuos en via publica y malos olores.',
      category: ReportCandidateCategory.basura,
      status: ReportCandidateStatus.pendienteRevision,
      priority: ReportCandidatePriority.media,
      locationText: 'Av. Paragua, Santa Cruz',
      lat: -17.7762,
      lng: -63.1812,
      citizenSupportCount: 31,
      commentsCount: 9,
      createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      suggestedSolution:
          'Programar limpieza, verificar frecuencia de recojo y comunicar canales de seguimiento.',
    ),
    ReportCandidate(
      id: 'candidate-alumbrado-sucre',
      postId: 'mock-alumbrado-sucre',
      title: 'Alumbrado publico danado en Sucre',
      summary:
          'La zona queda con baja iluminacion durante la noche, generando preocupacion vecinal.',
      category: ReportCandidateCategory.alumbrado,
      status: ReportCandidateStatus.rechazado,
      priority: ReportCandidatePriority.media,
      locationText: 'Recoleta, Sucre',
      lat: -19.0333,
      lng: -65.2627,
      citizenSupportCount: 18,
      commentsCount: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      suggestedSolution:
          'Verificar luminarias y coordinar mantenimiento con la unidad correspondiente.',
      rejectionReason: 'Falta evidencia fotografica para el informe formal.',
    ),
  ];
}
