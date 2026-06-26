import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '@common/entities/base.entity';
import { RssNewsItem } from './rss-news-item.entity';
import { ApiProperty } from '@nestjs/swagger';

@Entity('generated_news_posts')
export class GeneratedNewsPost extends BaseEntity {
  @ApiProperty({ required: false })
  @Column({ name: 'news_item_id', type: 'uuid', nullable: true })
  newsItemId: string | null;

  @ManyToOne(() => RssNewsItem, (item) => item.generatedPosts, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'news_item_id' })
  newsItem?: RssNewsItem;

  @ApiProperty()
  @Column({ type: 'text' })
  title: string;

  @ApiProperty()
  @Column({ type: 'text' })
  content: string;

  @ApiProperty()
  @Column({ type: 'text' })
  source: string;

  @ApiProperty()
  @Column({ name: 'original_url', type: 'text' })
  originalUrl: string;

  @ApiProperty()
  @Column({ type: 'text', default: 'novedad' })
  category: string;

  @ApiProperty()
  @Column({ type: 'text', default: 'published' })
  status: string;

  @ApiProperty()
  @Column({ name: 'generated_by', type: 'text', default: 'rss_polling' })
  generatedBy: string;

  @ApiProperty()
  @Column({ name: 'is_ai_generated', type: 'boolean', default: false })
  isAiGenerated: boolean;
}
