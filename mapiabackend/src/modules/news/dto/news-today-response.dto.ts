import { ApiProperty } from '@nestjs/swagger';

export class NewsTodayResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty({ nullable: true })
  description: string | null;

  @ApiProperty({ nullable: true })
  source: string | null;

  @ApiProperty({ nullable: true })
  url: string | null;

  @ApiProperty()
  publishedAt: string;

  @ApiProperty({ nullable: true })
  locationText: string | null;

  @ApiProperty({ nullable: true })
  lat: number | null;

  @ApiProperty({ nullable: true })
  lng: number | null;

  @ApiProperty()
  category: string;

  @ApiProperty()
  createdBy: string;

  @ApiProperty()
  locationStatus: string;
}
