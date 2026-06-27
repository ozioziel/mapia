import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/domain/repositories/post_repository.dart';

class RemotePostRepository implements PostRepository {
  RemotePostRepository({required PostsApi api}) : _api = api;

  final PostsApi _api;

  @override
  Future<PostEntity> getPostById(String postId) {
    return _api.fetchPostById(postId);
  }

  @override
  Future<List<CommentEntity>> getCommentsByPostId(String postId) {
    return _api.fetchComments(postId);
  }
}
