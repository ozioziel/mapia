import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

class UserPostsGrid extends StatelessWidget {
  const UserPostsGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  final List<ProfilePostEntity> posts;
  final ValueChanged<ProfilePostEntity> onPostTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _EmptyPosts();
    }

    return Column(
      children: [
        for (final post in posts) ...[
          _PostTile(post: post, onTap: () => onPostTap(post)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.onTap});

  final ProfilePostEntity post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4EAF1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4D6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: Color(0xFFFFA000),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textNavy,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE53935),
                    size: 18,
                  ),
                  Text(
                    '${post.likesCount}',
                    style: const TextStyle(
                      color: AppTheme.textNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
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

class _EmptyPosts extends StatelessWidget {
  const _EmptyPosts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: const Text(
        'Todavia no hay publicaciones.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.mutedText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
