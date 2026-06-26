import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { BaseEntity } from '@common/entities/base.entity';
import { User } from '@modules/users/entities/user.entity';
import { AlertReportImage } from './alert-report-image.entity';

export type ReportSeverity = 'normal' | 'low' | 'medium' | 'high';
export type AlertType =
  | 'stock_bajo'
  | 'sobreprecio'
  | 'bloqueo'
  | 'retraso_proveedor'
  | 'combustible'
  | 'producto_no_disponible'
  | 'otro';

@Entity('reports')
@Index('idx_reports_location', ['latitude', 'longitude'])
@Index('idx_reports_department', ['department'])
@Index('idx_reports_product', ['product'])
@Index('idx_reports_alert_type', ['alertType'])
@Index('idx_reports_severity', ['severity'])
@Index('idx_reports_created_at', ['createdAt'])
@Index('idx_reports_user_id', ['userId'])
export class AlertReport extends BaseEntity {
  @ApiPropertyOptional()
  @Column({ name: 'user_id', type: 'uuid', nullable: true })
  userId: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User | null;
  @ApiProperty()
  @Column({ type: 'text' })
  title: string;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  description: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  product: string | null;

  @ApiProperty()
  @Column({ name: 'alert_type', type: 'text' })
  alertType: AlertType;

  @ApiProperty({ enum: ['normal', 'low', 'medium', 'high'] })
  @Column({ type: 'text' })
  severity: ReportSeverity;

  @ApiProperty({ example: -16.495 })
  @Column({ type: 'double precision' })
  latitude: number;

  @ApiProperty({ example: -68.133 })
  @Column({ type: 'double precision' })
  longitude: number;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  department: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  municipality: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'text', nullable: true })
  zone: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'numeric', nullable: true })
  price: string | null;

  @ApiPropertyOptional()
  @Column({ name: 'source_text', type: 'text', nullable: true })
  sourceText: string | null;

  @ApiPropertyOptional()
  @Column({ type: 'numeric', nullable: true })
  confidence: string | null;

  @ApiProperty()
  @Column({ type: 'text', default: 'active' })
  status: string;

  @OneToMany(() => AlertReportImage, (image) => image.report)
  images?: AlertReportImage[];
}
