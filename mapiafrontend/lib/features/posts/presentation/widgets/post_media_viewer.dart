import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostMediaViewer extends StatelessWidget {
  const PostMediaViewer({super.key, required this.post});

  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    if (post.mediaUrl == null || post.mediaType != PostMediaType.image) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          post.mediaUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: post.type.option.color.withValues(alpha: 0.12),
              alignment: Alignment.center,
              child: Icon(
                post.type.option.icon,
                color: post.type.option.color,
                size: 42,
              ),
            );
          },
        ),
      ),
    );
  }
}
