import { Column, Entity, Index, OneToMany } from 'typeorm';
import { BaseEntity } from '@common/entities/base.entity';
import { GeneratedNewsPost } from './generated-news-post.entity';
import { ApiProperty } from '@nestjs/swagger';

@Entity('rss_news_items')
export class RssNewsItem extends BaseEntity {
  @ApiProperty()
  @Column({ type: 'text' })
  title: string;

  @ApiProperty()
  @Index('idx_rss_news_items_url', { unique: true })
  @Column({ type: 'text', unique: true })
  url: string;

  @ApiProperty()
  @Column({ type: 'text' })
  source: string;

  @ApiProperty({ required: false })
  @Column({ type: 'text', nullable: true })
  description: string | null;

  @ApiProperty({ required: false })
  @Column({ name: 'published_at', type: 'timestamptz', nullable: true })
  publishedAt: Date | null;

  @ApiProperty({ required: false })
  @Column({ name: 'location_text', type: 'text', nullable: true })
  locationText: string | null;

  @ApiProperty({ required: false })
  @Column({ type: 'double precision', nullable: true })
  lat: number | null;

  @ApiProperty({ required: false })
  @Column({ type: 'double precision', nullable: true })
  lng: number | null;

  @ApiProperty({ required: false })
  @Column({ type: 'text', nullable: true })
  category: string | null;

  @ApiProperty({ required: false })
  @Column({ name: 'created_by', type: 'text', nullable: true })
  createdBy: string | null;

  @ApiProperty({ required: false })
  @Column({ name: 'location_status', type: 'text', default: 'pending' })
  locationStatus: string;

  @ApiProperty({ required: false })
  @Column({ name: 'geocoding_error', type: 'text', nullable: true })
  geocodingError: string | null;

  @ApiProperty()
  @Column({ name: 'detected_at', type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  detectedAt: Date;

  @ApiProperty({ required: false })
  @Index('idx_rss_news_items_hash', { unique: true })
  @Column({ type: 'text', unique: true, nullable: true })
  hash: string | null;

  @OneToMany(() => GeneratedNewsPost, (post) => post.newsItem)
  generatedPosts?: GeneratedNewsPost[];
}
