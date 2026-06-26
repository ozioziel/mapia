import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RssNewsItem } from './entities/rss-news-item.entity';
import { GeneratedNewsPost } from './entities/generated-news-post.entity';

@Injectable()
export class NewsPostsService {
  private readonly logger = new Logger(NewsPostsService.name);

  constructor(
    @InjectRepository(GeneratedNewsPost)
    private readonly generatedPostRepository: Repository<GeneratedNewsPost>,
  ) {}

  async createPostFromNews(newsItem: RssNewsItem): Promise<GeneratedNewsPost> {
    // Evitar generar duplicados si ya tiene un post asociado
    const exists = await this.generatedPostRepository.findOne({
      where: { newsItemId: newsItem.id },
    });

    if (exists) {
      return exists;
    }

    const content = this.generatePostFromNewsTemplate(newsItem);

    const newPost = this.generatedPostRepository.create({
      newsItemId: newsItem.id,
      title: newsItem.title,
      content: content,
      source: newsItem.source,
      originalUrl: newsItem.url,
      category: 'novedad',
      status: 'published',
      generatedBy: 'rss_polling',
      isAiGenerated: false,
    });

    const savedPost = await this.generatedPostRepository.save(newPost);
    this.logger.log(`Publicación automática generada exitosamente para la noticia: ${newsItem.id}`);
    return savedPost;
  }

  generatePostFromNewsTemplate(newsItem: RssNewsItem): string {
    // TODO: aquí se conectará IA en el futuro.
    // Por ahora usar plantilla simple.
    return `MAPIA detectó una nueva novedad desde El Deber: ${newsItem.title}. Esta información podría ser relevante para personas que se mueven por la ciudad, planifican rutas o buscan estar al tanto de lo que ocurre en Bolivia.`;
  }
}
