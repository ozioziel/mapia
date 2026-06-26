import { ApiProperty } from '@nestjs/swagger';

export class GeneratedNewsPostResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  content: string;

  @ApiProperty()
  source: string;

  @ApiProperty()
  originalUrl: string;

  @ApiProperty()
  category: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  generatedBy: string;

  @ApiProperty()
  isAiGenerated: boolean;

  @ApiProperty()
  createdAt: string;

  @ApiProperty({ required: false, nullable: true })
  mapItemId?: string | null;

  @ApiProperty({ required: false, nullable: true })
  locationText?: string | null;

  @ApiProperty({ required: false, nullable: true })
  lat?: number | null;

  @ApiProperty({ required: false, nullable: true })
  lng?: number | null;

  @ApiProperty({ required: false, nullable: true })
  publishedAt?: string | null;
}
