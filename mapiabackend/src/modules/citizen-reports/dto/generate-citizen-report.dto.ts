import { IsOptional, IsString, MaxLength } from 'class-validator';

export class GenerateCitizenReportDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  municipality?: string;
}
