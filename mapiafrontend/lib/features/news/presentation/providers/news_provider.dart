import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/news/data/services/news_rss_service.dart';
import 'package:mapiafrontend/features/news/domain/entities/news_item.dart';

// Experimental: in-memory state only. Safe to delete with the news feature.
class NewsProvider extends ChangeNotifier {
  NewsProvider({this.service = const NewsRssService()});

  final NewsRssService service;

  bool _isLoading = false;
  String? _error;
  List<NewsItem> _items = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<NewsItem> get items => _items;

  Future<void> loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await service.fetchElDeberNews();
    } on NewsRssException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = 'No se pudieron cargar las noticias: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
