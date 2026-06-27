import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';
import 'package:mapiafrontend/features/reputation/presentation/widgets/reputation_badge.dart';

class MapPostPreviewCard extends StatelessWidget {
  const MapPostPreviewCard({
    super.key,
    required this.post,
    required this.onGoTap,
    required this.onClose,
  });

  final PostEntity post;
  final VoidCallback onGoTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final reputation = post.authorReputation == null
        ? authorReputationInfo(post.authorName)
        : reputationInfoFor(score: post.authorReputation, postsCount: 1);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 156),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: post.authorAvatarUrl == null
                        ? null
                        : NetworkImage(post.authorAvatarUrl!),
                    child: post.authorAvatarUrl == null
                        ? Text(
                            post.authorName.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                post.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textNavy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ReputationBadge(
                              reputation: reputation,
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textNavy,
                            fontSize: 16,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.mutedText,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: onGoTap,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    label: const Text(
                      'Ir a la publicacion',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
