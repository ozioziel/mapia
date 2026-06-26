import 'package:mapiafrontend/features/news/domain/entities/generated_news_post.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_status.dart';

abstract class NewsRepository {
  Future<List<GeneratedNewsPost>> getGeneratedPosts();
  Future<NewsStatus> getStatus();
  Future<void> refreshNews();
}
