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
}
