import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/domain/repositories/post_repository.dart';

class PostDetailProvider extends ChangeNotifier {
  PostDetailProvider({required this.postId, required PostRepository repository})
    : _repository = repository;

  final String postId;
  final PostRepository _repository;

  PostEntity? post;
  List<CommentEntity> comments = const [];
  bool isLoading = false;
  bool isMutating = false;
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

  Future<bool> setReaction(PostReaction reaction) async {
    if (isMutating) return false;
    isMutating = true;
    error = null;
    notifyListeners();
    try {
      if (post?.userReaction == reaction) {
        post = await _repository.removeReaction(postId);
      } else {
        post = await _repository.setReaction(postId, reaction);
      }
      return true;
    } catch (_) {
      error = 'No pudimos guardar tu reaccion.';
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> createComment(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || isMutating) return false;
    isMutating = true;
    error = null;
    notifyListeners();
    try {
      await _repository.createComment(postId, trimmed);
      final results = await Future.wait([
        _repository.getPostById(postId),
        _repository.getCommentsByPostId(postId),
      ]);
      post = results[0] as PostEntity;
      comments = results[1] as List<CommentEntity>;
      return true;
    } catch (_) {
      error = 'No pudimos publicar tu comentario.';
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> reportFalseInformation() async {
    if (isMutating) return false;
    isMutating = true;
    error = null;
    notifyListeners();
    try {
      await _repository.reportFalseInformation(postId);
      post = await _repository.getPostById(postId);
      return true;
    } catch (_) {
      error = 'No pudimos enviar el reporte o ya lo reportaste.';
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
