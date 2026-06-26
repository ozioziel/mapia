import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/posts/data/repositories/mock_post_repository.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/domain/repositories/post_repository.dart';

class PostDetailProvider extends ChangeNotifier {
  PostDetailProvider({
    required this.postId,
    this._repository = const MockPostRepository(),
  });

  final String postId;
  final PostRepository _repository;

  PostEntity? post;
  List<CommentEntity> comments = const [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPostById(postId),
        _repository.getCommentsByPostId(postId),
      ]);
      post = results[0] as PostEntity;
      comments = results[1] as List<CommentEntity>;
    } catch (_) {
      error = 'No pudimos cargar esta publicación.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
