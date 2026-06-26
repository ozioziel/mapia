import { Controller, Get, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags, ApiResponse } from '@nestjs/swagger';
import { Public } from '@common/decorators/public.decorator';
import { NewsService } from './news.service';
import { GeneratedNewsPostResponseDto } from './dto/generated-news-post-response.dto';
import { RssNewsItemResponseDto } from './dto/rss-news-item-response.dto';
import { NewsTodayResponseDto } from './dto/news-today-response.dto';

@ApiTags('news')
@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Public()
  @Get('generated-posts')
  @ApiOperation({ summary: 'Obtener las publicaciones generadas a partir de noticias RSS' })
  @ApiResponse({ type: [GeneratedNewsPostResponseDto] })
  async getGeneratedPosts(): Promise<GeneratedNewsPostResponseDto[]> {
    const posts = await this.newsService.getGeneratedPosts();
    return posts.map(post => ({
      id: post.id,
      title: post.title,
      content: post.content,
      source: post.source,
      originalUrl: post.originalUrl,
      category: post.category,
      status: post.status,
      generatedBy: post.generatedBy,
      isAiGenerated: post.isAiGenerated,
      createdAt: post.createdAt.toISOString(),
      mapItemId: post.newsItemId ?? post.id,
      locationText: post.newsItem?.locationText ?? null,
      lat: post.newsItem?.lat ?? null,
      lng: post.newsItem?.lng ?? null,
      publishedAt: (post.newsItem?.publishedAt ?? post.createdAt).toISOString(),
    }));
  }

  @Public()
  @Get('today')
  @ApiOperation({ summary: 'Obtener novedades del dia actual en zona horaria de Bolivia' })
  @ApiResponse({ type: [NewsTodayResponseDto] })
  async getTodayNews(): Promise<NewsTodayResponseDto[]> {
    return this.newsService.getTodayNews();
  }

  @Public()
  @Get('today/map')
  @ApiOperation({ summary: 'Obtener novedades del dia actual con ubicacion valida para el mapa' })
  @ApiResponse({ type: [NewsTodayResponseDto] })
  async getTodayMapNews(): Promise<NewsTodayResponseDto[]> {
    return this.newsService.getTodayMapNews();
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Forzar manualmente una revisión del RSS y la generación de posts' })
  async refreshNews(): Promise<{ success: boolean; newsCount: number; postsCount: number }> {
    const result = await this.newsService.runPolling();
    return {
      success: true,
      ...result,
    };
  }

  @Public()
  @Post('geocode-missing')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Intentar geocodificar novedades del dia sin coordenadas' })
  async geocodeMissing(): Promise<{ success: boolean; processed: number; geocoded: number; skipped: number }> {
    const result = await this.newsService.geocodeMissingTodayNews();
    return { success: true, ...result };
  }

  @Public()
  @Get('rss-items')
  @ApiOperation({ summary: 'Obtener las noticias RSS detectadas' })
  @ApiResponse({ type: [RssNewsItemResponseDto] })
  async getRssItems(): Promise<RssNewsItemResponseDto[]> {
    const items = await this.newsService.getRssNewsItems();
    return items.map(item => ({
      id: item.id,
      title: item.title,
      url: item.url,
      source: item.source,
      description: item.description,
      publishedAt: item.publishedAt ? item.publishedAt.toISOString() : null,
      detectedAt: item.detectedAt.toISOString(),
      hash: item.hash,
      createdAt: item.createdAt.toISOString(),
      updatedAt: item.updatedAt.toISOString(),
      locationText: item.locationText,
      lat: item.lat,
      lng: item.lng,
      category: item.category,
      createdBy: item.createdBy,
      locationStatus: item.locationStatus,
    }));
  }

  @Public()
  @Get('status')
  @ApiOperation({ summary: 'Obtener el estado del sistema de polling RSS' })
  async getStatus(): Promise<any> {
    return this.newsService.getStatus();
  }
}
