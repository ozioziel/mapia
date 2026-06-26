import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NewsController } from './news.controller';
import { NewsService } from './news.service';
import { RssPollingService } from './rss-polling.service';
import { NewsPostsService } from './news-posts.service';
import { RssNewsItem } from './entities/rss-news-item.entity';
import { GeneratedNewsPost } from './entities/generated-news-post.entity';
import { NewsClassifierService } from './news-classifier.service';

@Module({
  imports: [TypeOrmModule.forFeature([RssNewsItem, GeneratedNewsPost])],
  controllers: [NewsController],
  providers: [NewsService, RssPollingService, NewsPostsService, NewsClassifierService],
  exports: [NewsService],
})
export class NewsModule {}
