import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/news/data/repositories/news_repository_impl.dart';
import 'package:mapiafrontend/features/news/domain/entities/generated_news_post.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_status.dart';
import 'package:mapiafrontend/features/news/domain/repositories/news_repository.dart';

class NewsPostsProvider extends ChangeNotifier {
  NewsPostsProvider({this.repository = const NewsRepositoryImpl()});

  final NewsRepository repository;

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  List<GeneratedNewsPost> _posts = const [];
  NewsStatus? _status;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  List<GeneratedNewsPost> get posts => _posts;
  NewsStatus? get status => _status;

  Future<void> loadData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        repository.getGeneratedPosts(),
        repository.getStatus(),
      ]);

      _posts = results[0] as List<GeneratedNewsPost>;
      _status = results[1] as NewsStatus;
      _error = null;
    } catch (e) {
      _error = 'Error al cargar novedades: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshManual() async {
    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      await repository.refreshNews();
      await loadData(silent: true);
    } catch (e) {
      _error = 'Error al actualizar noticias: $e';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
