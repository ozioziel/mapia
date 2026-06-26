import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import {
  ReportCandidatePriority,
  ReportCandidateStatus,
} from '../entities/report-candidate.entity';

export class UpdateReportCandidateStatusDto {
  @IsEnum(ReportCandidateStatus)
  status: ReportCandidateStatus;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  rejectionReason?: string;
}

export class UpdateReportCandidatePriorityDto {
  @IsEnum(ReportCandidatePriority)
  priority: ReportCandidatePriority;
}
