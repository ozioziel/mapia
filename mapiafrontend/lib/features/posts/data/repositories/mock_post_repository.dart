import 'package:mapiafrontend/features/posts/data/datasources/mock_posts_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/domain/repositories/post_repository.dart';

class MockPostRepository implements PostRepository {
  const MockPostRepository({this.datasource = const MockPostsDatasource()});

  final MockPostsDatasource datasource;

  @override
  Future<PostEntity> getPostById(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final post = datasource.getPostById(postId);
    if (post == null) {
      throw StateError('Publicación no encontrada');
    }
    return post;
  }

  @override
  Future<List<CommentEntity>> getCommentsByPostId(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return datasource.getCommentsByPostId(postId);
  }
}
