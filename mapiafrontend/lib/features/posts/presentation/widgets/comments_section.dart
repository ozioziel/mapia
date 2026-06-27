import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';

class CommentsSection extends StatelessWidget {
  const CommentsSection({super.key, required this.comments});

  final List<CommentEntity> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.comments,
          style: const TextStyle(
            color: AppTheme.textNavy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Todavia no hay comentarios.',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        for (final comment in comments) ...[
          _CommentTile(comment: comment),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommentEntity comment;

  @override
  Widget build(BuildContext context) {
    final initial = comment.authorName.trim().isEmpty
        ? 'M'
        : comment.authorName.characters.first.toUpperCase();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFFE7F7EF),
          backgroundImage: comment.authorAvatarUrl == null
              ? null
              : NetworkImage(comment.authorAvatarUrl!),
          child: comment.authorAvatarUrl == null
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF0B8063),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Color(0xFF4F5B6B),
                    fontSize: 13.5,
                    height: 1.32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
