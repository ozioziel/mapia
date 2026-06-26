import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<PostEntity> getPostById(String postId);

  Future<List<CommentEntity>> getCommentsByPostId(String postId);
}
