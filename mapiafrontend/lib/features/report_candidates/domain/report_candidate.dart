enum ReportCandidateCategory {
  bloqueo,
  corteServicio,
  basura,
  bache,
  alumbrado,
  transporte,
  seguridad,
  evento,
  ventaIrregular,
  otroProblemaUrbano,
}

enum ReportCandidateStatus {
  pendienteRevision,
  aprobadoParaInforme,
  rechazado,
  incluidoEnInforme,
  enviado,
  resuelto,
}

enum ReportCandidatePriority { baja, media, alta, urgente }

class ReportCandidate {
  const ReportCandidate({
    required this.id,
    required this.postId,
    required this.title,
    required this.summary,
    required this.category,
    required this.status,
    required this.priority,
    required this.citizenSupportCount,
    required this.commentsCount,
    required this.createdAt,
    this.locationText,
    this.lat,
    this.lng,
    this.evidenceUrls = const [],
    this.aiSummary,
    this.suggestedSolution,
    this.rejectionReason,
  });

  final String id;
  final String postId;
  final String title;
  final String summary;
  final ReportCandidateCategory category;
  final ReportCandidateStatus status;
  final ReportCandidatePriority priority;
  final String? locationText;
  final double? lat;
  final double? lng;
  final List<String> evidenceUrls;
  final int citizenSupportCount;
  final int commentsCount;
  final DateTime createdAt;
  final String? aiSummary;
  final String? suggestedSolution;
  final String? rejectionReason;

  ReportCandidate copyWith({
    ReportCandidateStatus? status,
    ReportCandidatePriority? priority,
    String? rejectionReason,
  }) {
    return ReportCandidate(
      id: id,
      postId: postId,
      title: title,
      summary: summary,
      category: category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      locationText: locationText,
      lat: lat,
      lng: lng,
      evidenceUrls: evidenceUrls,
      citizenSupportCount: citizenSupportCount,
      commentsCount: commentsCount,
      createdAt: createdAt,
      aiSummary: aiSummary,
      suggestedSolution: suggestedSolution,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class GeneratedCitizenReport {
  const GeneratedCitizenReport({
    required this.title,
    required this.generatedAt,
    required this.municipality,
    required this.candidatesCount,
    required this.body,
    required this.note,
  });

  final String title;
  final DateTime generatedAt;
  final String municipality;
  final int candidatesCount;
  final String body;
  final String note;
}

extension ReportCandidateCategoryText on ReportCandidateCategory {
  String get apiValue {
    return switch (this) {
      ReportCandidateCategory.bloqueo => 'bloqueo',
      ReportCandidateCategory.corteServicio => 'corte_servicio',
      ReportCandidateCategory.basura => 'basura',
      ReportCandidateCategory.bache => 'bache',
      ReportCandidateCategory.alumbrado => 'alumbrado',
      ReportCandidateCategory.transporte => 'transporte',
      ReportCandidateCategory.seguridad => 'seguridad',
      ReportCandidateCategory.evento => 'evento',
      ReportCandidateCategory.ventaIrregular => 'venta_irregular',
      ReportCandidateCategory.otroProblemaUrbano => 'otro_problema_urbano',
    };
  }

  String get label {
    return switch (this) {
      ReportCandidateCategory.bloqueo => 'Bloqueo',
      ReportCandidateCategory.corteServicio => 'Corte de servicio',
      ReportCandidateCategory.basura => 'Basura',
      ReportCandidateCategory.bache => 'Bache',
      ReportCandidateCategory.alumbrado => 'Alumbrado',
      ReportCandidateCategory.transporte => 'Transporte',
      ReportCandidateCategory.seguridad => 'Seguridad',
      ReportCandidateCategory.evento => 'Evento',
      ReportCandidateCategory.ventaIrregular => 'Venta irregular',
      ReportCandidateCategory.otroProblemaUrbano => 'Otro problema urbano',
    };
  }
}

extension ReportCandidateStatusText on ReportCandidateStatus {
  String get apiValue {
    return switch (this) {
      ReportCandidateStatus.pendienteRevision => 'pendiente_revision',
      ReportCandidateStatus.aprobadoParaInforme => 'aprobado_para_informe',
      ReportCandidateStatus.rechazado => 'rechazado',
      ReportCandidateStatus.incluidoEnInforme => 'incluido_en_informe',
      ReportCandidateStatus.enviado => 'enviado',
      ReportCandidateStatus.resuelto => 'resuelto',
    };
  }

  String get label {
    return switch (this) {
      ReportCandidateStatus.pendienteRevision => 'Pendiente',
      ReportCandidateStatus.aprobadoParaInforme => 'Aprobado',
      ReportCandidateStatus.rechazado => 'Rechazado',
      ReportCandidateStatus.incluidoEnInforme => 'En informe',
      ReportCandidateStatus.enviado => 'Enviado',
      ReportCandidateStatus.resuelto => 'Resuelto',
    };
  }
}

extension ReportCandidatePriorityText on ReportCandidatePriority {
  String get apiValue {
    return switch (this) {
      ReportCandidatePriority.baja => 'baja',
      ReportCandidatePriority.media => 'media',
      ReportCandidatePriority.alta => 'alta',
      ReportCandidatePriority.urgente => 'urgente',
    };
  }

  String get label {
    return switch (this) {
      ReportCandidatePriority.baja => 'Baja',
      ReportCandidatePriority.media => 'Media',
      ReportCandidatePriority.alta => 'Alta',
      ReportCandidatePriority.urgente => 'Urgente',
    };
  }
}

ReportCandidateCategory reportCategoryFromApi(String? value) {
  return ReportCandidateCategory.values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => ReportCandidateCategory.otroProblemaUrbano,
  );
}

ReportCandidateStatus reportStatusFromApi(String? value) {
  return ReportCandidateStatus.values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => ReportCandidateStatus.pendienteRevision,
  );
}

ReportCandidatePriority reportPriorityFromApi(String? value) {
  return ReportCandidatePriority.values.firstWhere(
    (priority) => priority.apiValue == value,
    orElse: () => ReportCandidatePriority.media,
  );
}
