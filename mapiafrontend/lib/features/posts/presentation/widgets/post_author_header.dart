import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostAuthorHeader extends StatelessWidget {
  const PostAuthorHeader({super.key, required this.post});

  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    final type = post.type.option;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: type.color.withValues(alpha: 0.13),
          backgroundImage: post.authorAvatarUrl == null
              ? null
              : NetworkImage(post.authorAvatarUrl!),
          child: post.authorAvatarUrl == null
              ? Text(
                  post.authorName.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: type.color,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_timeAgo(post.createdAt)} · ${post.address ?? 'La Paz'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _timeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'Ahora';
  if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
  return 'Hace ${difference.inDays} d';
}
