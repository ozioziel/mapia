import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { RssPollingService } from './rss-polling.service';
import { NewsPostsService } from './news-posts.service';
import { RssNewsItem } from './entities/rss-news-item.entity';
import { GeneratedNewsPost } from './entities/generated-news-post.entity';

@Injectable()
export class NewsService {
  private readonly logger = new Logger(NewsService.name);
  private lastPollTime: Date | null = null;

  constructor(
    private readonly rssPollingService: RssPollingService,
    private readonly newsPostsService: NewsPostsService,
    @InjectRepository(RssNewsItem)
    private readonly newsItemRepository: Repository<RssNewsItem>,
    @InjectRepository(GeneratedNewsPost)
    private readonly generatedPostRepository: Repository<GeneratedNewsPost>,
  ) {}

  // Cron programado para ejecutarse cada 30 minutos
  @Cron(CronExpression.EVERY_30_MINUTES)
  async handleCronPolling(): Promise<void> {
    this.logger.log('Iniciando polling programado de RSS...');
    await this.runPolling();
  }

  async runPolling(): Promise<{ newsCount: number; postsCount: number }> {
    this.lastPollTime = new Date();
    
    // 1. Obtener noticias nuevas de RSS
    const newItems = await this.rssPollingService.pollAllSources();
    this.logger.log(`Se detectaron ${newItems.length} noticias nuevas.`);

    // 2. Generar publicaciones automáticas para cada noticia nueva
    let createdPostsCount = 0;
    for (const item of newItems) {
      try {
        await this.newsPostsService.createPostFromNews(item);
        createdPostsCount++;
      } catch (error) {
        this.logger.error(`Error al generar publicación para la noticia ${item.id}: ${error.message}`);
      }
    }

    return {
      newsCount: newItems.length,
      postsCount: createdPostsCount,
    };
  }

  async getGeneratedPosts(): Promise<GeneratedNewsPost[]> {
    return this.generatedPostRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async getRssNewsItems(): Promise<RssNewsItem[]> {
    return this.newsItemRepository.find({
      order: { detectedAt: 'DESC' },
    });
  }

  async getStatus(): Promise<any> {
    const newsCount = await this.newsItemRepository.count();
    const postsCount = await this.generatedPostRepository.count();
    const sources = this.rssPollingService.getSources().map(s => s.name);

    return {
      lastPollTime: this.lastPollTime ? this.lastPollTime.toISOString() : null,
      totalNewsDetected: newsCount,
      totalPostsGenerated: postsCount,
      activeSources: sources,
      configuredInterval: 'Cada 30 minutos',
    };
  }
}
