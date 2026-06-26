import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '@common/entities/base.entity';
import { Post } from '@modules/posts/entities/post.entity';
import { User } from '@modules/users/entities/user.entity';

export enum ReportCandidateCategory {
  BLOQUEO = 'bloqueo',
  CORTE_SERVICIO = 'corte_servicio',
  BASURA = 'basura',
  BACHE = 'bache',
  ALUMBRADO = 'alumbrado',
  TRANSPORTE = 'transporte',
  SEGURIDAD = 'seguridad',
  EVENTO = 'evento',
  VENTA_IRREGULAR = 'venta_irregular',
  OTRO_PROBLEMA_URBANO = 'otro_problema_urbano',
}

export enum ReportCandidateStatus {
  PENDIENTE_REVISION = 'pendiente_revision',
  APROBADO_PARA_INFORME = 'aprobado_para_informe',
  RECHAZADO = 'rechazado',
  INCLUIDO_EN_INFORME = 'incluido_en_informe',
  ENVIADO = 'enviado',
  RESUELTO = 'resuelto',
}

export enum ReportCandidatePriority {
  BAJA = 'baja',
  MEDIA = 'media',
  ALTA = 'alta',
  URGENTE = 'urgente',
}

@Entity('report_candidates')
@Index('idx_report_candidates_status', ['status'])
@Index('idx_report_candidates_category', ['category'])
@Index('idx_report_candidates_post', ['postId'], { unique: true })
export class ReportCandidate extends BaseEntity {
  @ApiProperty({ format: 'uuid' })
  @Column({ name: 'post_id', type: 'uuid' })
  postId: string;

  @ManyToOne(() => Post, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post?: Post;

  @ApiProperty()
  @Column({ type: 'text' })
  title: string;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  summary: string | null;

  @ApiProperty({ enum: ReportCandidateCategory })
  @Column({ type: 'text' })
  category: ReportCandidateCategory;

  @ApiProperty({ enum: ReportCandidateStatus })
  @Column({ type: 'text', default: ReportCandidateStatus.PENDIENTE_REVISION })
  status: ReportCandidateStatus;

  @ApiProperty({ enum: ReportCandidatePriority })
  @Column({ type: 'text', default: ReportCandidatePriority.MEDIA })
  priority: ReportCandidatePriority;

  @ApiPropertyOptional()
  @Column({ name: 'location_text', type: 'text', nullable: true })
  locationText: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'double precision', nullable: true })
  lat: number | null;

  @ApiPropertyOptional()
  @Column({ type: 'double precision', nullable: true })
  lng: number | null;

  @ApiProperty({ type: [String] })
  @Column({ name: 'evidence_urls', type: 'text', array: true, default: () => "'{}'" })
  evidenceUrls: string[];

  @ApiProperty()
  @Column({ name: 'citizen_support_count', type: 'int', default: 0 })
  citizenSupportCount: number;

  @ApiProperty()
  @Column({ name: 'comments_count', type: 'int', default: 0 })
  commentsCount: number;

  @ApiPropertyOptional()
  @Column({ name: 'ai_summary', type: 'text', nullable: true })
  aiSummary: string | null;

  @ApiPropertyOptional()
  @Column({ name: 'suggested_solution', type: 'text', nullable: true })
  suggestedSolution: string | null;

  @ApiPropertyOptional({ format: 'uuid' })
  @Column({ name: 'reviewed_by', type: 'uuid', nullable: true })
  reviewedBy: string | null;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'reviewed_by' })
  reviewer?: User | null;

  @ApiPropertyOptional()
  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt: Date | null;

  @ApiPropertyOptional()
  @Column({ name: 'rejection_reason', type: 'text', nullable: true })
  rejectionReason: string | null;
}
