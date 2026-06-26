import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PostType } from '@common/enums/post.enums';
import { PostsService } from '@modules/posts/posts.service';
import {
  ReportCandidate,
  ReportCandidateCategory,
  ReportCandidatePriority,
  ReportCandidateStatus,
} from './entities/report-candidate.entity';
import {
  UpdateReportCandidatePriorityDto,
  UpdateReportCandidateStatusDto,
} from './dto/report-candidate.dto';

const BOLIVIA_BOUNDS = {
  minLat: -22.9,
  maxLat: -9.6,
  minLng: -69.7,
  maxLng: -57.4,
};

@Injectable()
export class ReportCandidatesService {
  constructor(
    @InjectRepository(ReportCandidate)
    private readonly candidateRepo: Repository<ReportCandidate>,
    private readonly postsService: PostsService,
  ) {}

  async findAll(status?: ReportCandidateStatus): Promise<{ items: ReportCandidate[] }> {
    const items = await this.candidateRepo.find({
      where: status ? { status } : {},
      order: { createdAt: 'DESC' },
      take: 200,
    });
    return { items };
  }

  async approved(): Promise<{ items: ReportCandidate[] }> {
    return this.findAll(ReportCandidateStatus.APROBADO_PARA_INFORME);
  }

  async approvedMapMarkers() {
    const { items } = await this.approved();
    return {
      items: items
        .filter((candidate) => candidate.lat !== null && candidate.lng !== null)
        .map((candidate) => ({
          id: candidate.id,
          postId: candidate.postId,
          title: candidate.title,
          category: candidate.category,
          priority: candidate.priority,
          summary: candidate.summary ?? candidate.aiSummary ?? 'Informacion no disponible',
          locationText: candidate.locationText,
          latitude: candidate.lat,
          longitude: candidate.lng,
        })),
    };
  }

  async createFromPost(postId: string): Promise<ReportCandidate> {
    const post = await this.postsService.getVisibleEntityOrFail(postId);
    const existing = await this.candidateRepo.findOne({ where: { postId } });
    if (existing) {
      throw new ConflictException('Esta publicacion ya esta marcada como candidata');
    }

    const evidenceUrls = (post.media ?? []).map((media) => media.url).filter(Boolean);
    const candidate = this.candidateRepo.create({
      postId: post.id,
      title: post.title,
      summary: post.description,
      category: inferCategory(post.type, `${post.title} ${post.description}`),
      status: ReportCandidateStatus.PENDIENTE_REVISION,
      priority: inferPriority(post.likesCount, post.commentsCount, post.type),
      locationText: post.address ?? null,
      lat: isInsideBolivia(post.latitude, post.longitude) ? post.latitude : null,
      lng: isInsideBolivia(post.latitude, post.longitude) ? post.longitude : null,
      evidenceUrls,
      citizenSupportCount: post.likesCount,
      commentsCount: post.commentsCount,
      aiSummary: buildSafeSummary(post.description),
      suggestedSolution: suggestSolution(post.type),
    });

    return this.candidateRepo.save(candidate);
  }

  async updateStatus(
    id: string,
    reviewerId: string,
    dto: UpdateReportCandidateStatusDto,
  ): Promise<ReportCandidate> {
    const candidate = await this.getById(id);
    candidate.status = dto.status;
    candidate.reviewedBy = reviewerId;
    candidate.reviewedAt = new Date();
    candidate.rejectionReason =
      dto.status === ReportCandidateStatus.RECHAZADO ? (dto.rejectionReason ?? null) : null;
    return this.candidateRepo.save(candidate);
  }

  async updatePriority(
    id: string,
    dto: UpdateReportCandidatePriorityDto,
  ): Promise<ReportCandidate> {
    const candidate = await this.getById(id);
    candidate.priority = dto.priority;
    return this.candidateRepo.save(candidate);
  }

  async getApprovedForFormalReport(): Promise<ReportCandidate[]> {
    const { items } = await this.approved();
    return items;
  }

  private async getById(id: string): Promise<ReportCandidate> {
    const candidate = await this.candidateRepo.findOne({ where: { id } });
    if (!candidate) {
      throw new NotFoundException('Candidato no encontrado');
    }
    return candidate;
  }
}

function isInsideBolivia(lat: number, lng: number): boolean {
  return (
    lat >= BOLIVIA_BOUNDS.minLat &&
    lat <= BOLIVIA_BOUNDS.maxLat &&
    lng >= BOLIVIA_BOUNDS.minLng &&
    lng <= BOLIVIA_BOUNDS.maxLng
  );
}

function inferCategory(type: PostType, text: string): ReportCandidateCategory {
  const normalized = normalize(text);
  if (type === PostType.BLOCKADE || normalized.includes('bloqueo')) {
    return ReportCandidateCategory.BLOQUEO;
  }
  if (type === PostType.SERVICE_CUT || normalized.includes('corte')) {
    return ReportCandidateCategory.CORTE_SERVICIO;
  }
  if (type === PostType.TRAFFIC) return ReportCandidateCategory.TRANSPORTE;
  if (type === PostType.SECURITY) return ReportCandidateCategory.SEGURIDAD;
  if (type === PostType.PARTY) return ReportCandidateCategory.EVENTO;
  if (type === PostType.SALE) return ReportCandidateCategory.VENTA_IRREGULAR;
  if (normalized.includes('basura')) return ReportCandidateCategory.BASURA;
  if (normalized.includes('bache')) return ReportCandidateCategory.BACHE;
  if (normalized.includes('alumbrado') || normalized.includes('luz')) {
    return ReportCandidateCategory.ALUMBRADO;
  }
  return ReportCandidateCategory.OTRO_PROBLEMA_URBANO;
}

function inferPriority(
  likesCount: number,
  commentsCount: number,
  type: PostType,
): ReportCandidatePriority {
  const score = likesCount + commentsCount * 2;
  if (type === PostType.BLOCKADE && score >= 30) return ReportCandidatePriority.URGENTE;
  if (score >= 60) return ReportCandidatePriority.URGENTE;
  if (score >= 25) return ReportCandidatePriority.ALTA;
  if (score >= 8) return ReportCandidatePriority.MEDIA;
  return ReportCandidatePriority.BAJA;
}

function buildSafeSummary(description: string): string {
  const clean = description.trim();
  if (!clean) return 'Informacion no disponible';
  return clean.length <= 500 ? clean : `${clean.slice(0, 497)}...`;
}

function suggestSolution(type: PostType): string {
  const suggestions: Partial<Record<PostType, string>> = {
    [PostType.BLOCKADE]: 'Coordinar verificacion en via publica y plan de desvio temporal.',
    [PostType.SERVICE_CUT]:
      'Solicitar verificacion tecnica y comunicacion de horarios de reposicion.',
    [PostType.TRAFFIC]: 'Evaluar control vial y senalizacion preventiva en la zona.',
    [PostType.SECURITY]:
      'Derivar a la instancia municipal competente para patrullaje o iluminacion.',
    [PostType.PARTY]: 'Verificar permisos, horarios y condiciones de seguridad del evento.',
    [PostType.SALE]: 'Verificar autorizacion municipal y condiciones de uso del espacio publico.',
  };
  return suggestions[type] ?? 'Realizar inspeccion municipal y definir accion correctiva.';
}

function normalize(value: string): string {
  return value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}
