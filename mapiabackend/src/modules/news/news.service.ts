import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { RssPollingService } from './rss-polling.service';
import { NewsPostsService } from './news-posts.service';
import { RssNewsItem } from './entities/rss-news-item.entity';
import { GeneratedNewsPost } from './entities/generated-news-post.entity';
import { NewsTodayResponseDto } from './dto/news-today-response.dto';
import { GeocodingService } from './geocoding.service';
import {
  getBoliviaDayRange,
  inferLocationText,
  isInsideBolivia,
  normalizeNewsCategory,
} from './news-location.utils';
import { buildMockTodayNews } from './mock-today-news';

@Injectable()
export class NewsService {
  private readonly logger = new Logger(NewsService.name);
  private lastPollTime: Date | null = null;

  constructor(
    private readonly rssPollingService: RssPollingService,
    private readonly newsPostsService: NewsPostsService,
    private readonly geocodingService: GeocodingService,
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
      relations: { newsItem: true },
      order: { createdAt: 'DESC' },
    });
  }

  async getRssNewsItems(): Promise<RssNewsItem[]> {
    return this.newsItemRepository.find({
      order: { detectedAt: 'DESC' },
    });
  }

  async getTodayNews(): Promise<NewsTodayResponseDto[]> {
    const items = await this.getTodayNewsItems();
    const mapped = items.map((item) => this.toTodayResponse(item));
    return mapped.length > 0 ? mapped : buildMockTodayNews();
  }

  async getTodayMapNews(): Promise<NewsTodayResponseDto[]> {
    const items = await this.getTodayNewsItems();
    if (items.length === 0) return buildMockTodayNews();

    const readyItems: RssNewsItem[] = [];
    for (const item of items) {
      const prepared = await this.ensureLocation(item);
      if (prepared.lat == null || prepared.lng == null) continue;
      if (!isInsideBolivia(prepared.lat, prepared.lng)) continue;
      readyItems.push(prepared);
    }

    return readyItems.map((item) => this.toTodayResponse(item));
  }

  async geocodeMissingTodayNews(): Promise<{ processed: number; geocoded: number; skipped: number }> {
    const items = await this.getTodayNewsItems();
    let geocoded = 0;
    let skipped = 0;

    for (const item of items) {
      const hadLocation = item.lat != null && item.lng != null;
      const prepared = await this.ensureLocation(item);
      if (!hadLocation && prepared.lat != null && prepared.lng != null) {
        geocoded++;
      } else if (prepared.lat == null || prepared.lng == null) {
        skipped++;
      }
    }

    return { processed: items.length, geocoded, skipped };
  }

  private async getTodayNewsItems(): Promise<RssNewsItem[]> {
    const { start, end } = getBoliviaDayRange();
    return this.newsItemRepository
      .createQueryBuilder('news')
      .where('COALESCE(news.published_at, news.created_at) >= :start', {
        start: start.toISOString(),
      })
      .andWhere('COALESCE(news.published_at, news.created_at) < :end', {
        end: end.toISOString(),
      })
      .orderBy('COALESCE(news.published_at, news.created_at)', 'DESC')
      .getMany();
  }

  private async ensureLocation(item: RssNewsItem): Promise<RssNewsItem> {
    if (item.lat != null && item.lng != null) {
      if (isInsideBolivia(item.lat, item.lng)) return item;
      item.locationStatus = 'outside_bolivia';
      item.geocodingError = 'Coordenadas fuera de Bolivia';
      return this.newsItemRepository.save(item);
    }

    const locationText =
      item.locationText ?? inferLocationText(item.title, item.description);
    if (!locationText) {
      item.locationStatus = 'without_location';
      item.geocodingError = 'No se encontro una ubicacion probable';
      return this.newsItemRepository.save(item);
    }

    const geocoded = await this.geocodingService.geocodeBoliviaLocation(locationText);
    if (!geocoded) {
      item.locationText = locationText;
      item.locationStatus = 'without_location';
      item.geocodingError = 'Geocoding sin resultado confiable en Bolivia';
      return this.newsItemRepository.save(item);
    }

    item.locationText = geocoded.formattedAddress ?? locationText;
    item.lat = geocoded.lat;
    item.lng = geocoded.lng;
    item.locationStatus = 'geocoded';
    item.geocodingError = null;
    return this.newsItemRepository.save(item);
  }

  private toTodayResponse(item: RssNewsItem): NewsTodayResponseDto {
    return {
      id: item.id,
      title: item.title,
      description: item.description,
      source: item.source,
      url: item.url,
      publishedAt: (item.publishedAt ?? item.createdAt).toISOString(),
      locationText: item.locationText,
      lat: item.lat,
      lng: item.lng,
      category: normalizeNewsCategory(item.category),
      createdBy: item.createdBy ?? 'rss',
      locationStatus: item.locationStatus ?? 'pending',
    };
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
