import { ApiProperty } from '@nestjs/swagger';

export class RssNewsItemResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  url: string;

  @ApiProperty()
  source: string;

  @ApiProperty({ required: false, nullable: true })
  description: string | null;

  @ApiProperty({ required: false, nullable: true })
  publishedAt: string | null;

  @ApiProperty()
  detectedAt: string;

  @ApiProperty({ required: false, nullable: true })
  hash: string | null;

  @ApiProperty()
  createdAt: string;

  @ApiProperty()
  updatedAt: string;
}
