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
