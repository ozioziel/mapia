import { Controller, Get, Post, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags, ApiResponse } from '@nestjs/swagger';
import { Public } from '@common/decorators/public.decorator';
import { NewsService } from './news.service';
import { GeneratedNewsPostResponseDto } from './dto/generated-news-post-response.dto';
import { RssNewsItemResponseDto } from './dto/rss-news-item-response.dto';

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
    }));
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
    }));
  }

  @Public()
  @Get('status')
  @ApiOperation({ summary: 'Obtener el estado del sistema de polling RSS' })
  async getStatus(): Promise<any> {
    return this.newsService.getStatus();
  }
}
