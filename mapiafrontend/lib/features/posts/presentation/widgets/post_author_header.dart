import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/time_ago.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';
import 'package:mapiafrontend/features/reputation/presentation/widgets/reputation_badge.dart';

class PostAuthorHeader extends StatelessWidget {
  const PostAuthorHeader({super.key, required this.post});

  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    final type = post.type.option;
    final reputation = authorReputationInfo(post.authorName);

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
                '${localizedTimeAgo(context, post.createdAt)} - ${post.address ?? context.l10n.laPaz}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ReputationBadge(reputation: reputation),
            ],
          ),
        ),
      ],
    );
  }
}
