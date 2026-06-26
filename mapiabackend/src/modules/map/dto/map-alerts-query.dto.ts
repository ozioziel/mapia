import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsISO8601, IsOptional, IsString, Length } from 'class-validator';
import { ALERT_TYPES, REPORT_SEVERITIES } from '@modules/reports/dto/create-citizen-report.dto';
import { AlertType, ReportSeverity } from '@modules/reports/entities/alert-report.entity';

export class MapAlertsQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Length(1, 120)
  department?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Length(1, 120)
  municipality?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Length(1, 160)
  zone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Length(1, 120)
  product?: string;

  @ApiPropertyOptional({ enum: ALERT_TYPES })
  @IsOptional()
  @IsEnum(ALERT_TYPES)
  alertType?: AlertType;

  @ApiPropertyOptional({ enum: REPORT_SEVERITIES })
  @IsOptional()
  @IsEnum(REPORT_SEVERITIES)
  severity?: ReportSeverity;

  @ApiPropertyOptional()
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsISO8601()
  to?: string;
}
