import { Injectable } from '@nestjs/common';
import { ReportCandidate } from '@modules/report-candidates/entities/report-candidate.entity';
import { ReportCandidatesService } from '@modules/report-candidates/report-candidates.service';
import { GenerateCitizenReportDto } from './dto/generate-citizen-report.dto';

@Injectable()
export class CitizenReportsService {
  constructor(private readonly candidatesService: ReportCandidatesService) {}

  async generate(dto: GenerateCitizenReportDto) {
    const candidates = await this.candidatesService.getApprovedForFormalReport();
    const generatedAt = new Date();
    const municipality = dto.municipality?.trim() || 'Informacion no disponible';
    const body = buildFormalReport(candidates, generatedAt, municipality);

    return {
      title: 'Informe ciudadano de problematicas urbanas reportadas en MAPIA',
      generatedAt: generatedAt.toISOString(),
      municipality,
      candidatesCount: candidates.length,
      status: 'draft_review_required',
      note: 'Este informe es un borrador para revision humana/admin. No fue enviado automaticamente.',
      body,
    };
  }
}

function buildFormalReport(
  candidates: ReportCandidate[],
  generatedAt: Date,
  municipality: string,
): string {
  const date = new Intl.DateTimeFormat('es-BO', {
    dateStyle: 'long',
    timeZone: 'America/La_Paz',
  }).format(generatedAt);

  const lines = [
    'Informe ciudadano de problematicas urbanas reportadas en MAPIA',
    '',
    '1. Fecha del informe',
    date,
    '',
    '2. Ciudad o municipio',
    municipality,
    '',
    '3. Resumen ejecutivo',
    candidates.length === 0
      ? 'No existen candidatos aprobados para informe al momento de generar este borrador.'
      : `El presente informe consolida ${candidates.length} caso(s) ciudadano(s) revisados y aprobados en MAPIA para consideracion institucional. La informacion se presenta con enfoque preventivo, respetuoso y orientado a solucion.`,
    '',
    '4. Lista de problemas reportados',
    ...formatCandidateList(candidates),
    '',
    '10. Conclusion formal',
    'Se remite este borrador para revision interna antes de cualquier comunicacion externa. La informacion debe ser validada por una persona administradora y, cuando corresponda, complementada con verificacion territorial. El objetivo es facilitar una respuesta coordinada, clara y orientada a soluciones para la ciudadania.',
  ];

  return lines.join('\n');
}

function formatCandidateList(candidates: ReportCandidate[]): string[] {
  if (candidates.length === 0) return ['Informacion no disponible'];

  return candidates.flatMap((candidate, index) => [
    `${index + 1}. ${candidate.title}`,
    `   Categoria: ${candidate.category}`,
    `   Resumen: ${candidate.summary || candidate.aiSummary || 'Informacion no disponible'}`,
    `   Ubicacion: ${candidate.locationText || 'Informacion no disponible'}`,
    `   Coordenadas: ${formatCoordinates(candidate)}`,
    `   Evidencia disponible: ${formatEvidence(candidate.evidenceUrls)}`,
    `   Nivel de prioridad: ${candidate.priority}`,
    `   Apoyo ciudadano: ${candidate.citizenSupportCount} apoyo(s), ${candidate.commentsCount} comentario(s)`,
    `   Posible solucion sugerida: ${candidate.suggestedSolution || 'Informacion no disponible'}`,
    '',
  ]);
}

function formatCoordinates(candidate: ReportCandidate): string {
  if (candidate.lat === null || candidate.lng === null) return 'Informacion no disponible';
  return `${candidate.lat}, ${candidate.lng}`;
}

function formatEvidence(evidenceUrls: string[]): string {
  return evidenceUrls.length ? evidenceUrls.join(', ') : 'Informacion no disponible';
}
