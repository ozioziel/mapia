import 'package:mapiafrontend/features/news/data/datasources/news_remote_data_source.dart';
import 'package:mapiafrontend/features/news/domain/entities/generated_news_post.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_status.dart';
import 'package:mapiafrontend/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl({this.dataSource = const NewsRemoteDataSource()});

  final NewsRemoteDataSource dataSource;

  @override
  Future<List<GeneratedNewsPost>> getGeneratedPosts() async {
    return dataSource.fetchGeneratedPosts();
  }

  @override
  Future<NewsStatus> getStatus() async {
    return dataSource.fetchStatus();
  }

  @override
  Future<void> refreshNews() async {
    return dataSource.refreshNews();
  }
}
