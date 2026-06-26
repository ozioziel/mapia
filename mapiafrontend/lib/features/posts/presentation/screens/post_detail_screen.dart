import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/presentation/providers/post_detail_provider.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/comment_input.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/comments_section.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_author_header.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_interaction_bar.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_media_viewer.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostDetailProvider _provider;
  bool? _likedOverride;
  int? _likesOverride;

  @override
  void initState() {
    super.initState();
    _provider = PostDetailProvider(postId: widget.postId)..load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _toggleLike(PostEntity post) {
    final currentLiked = _likedOverride ?? post.isLiked;
    final currentLikes = _likesOverride ?? post.likesCount;
    setState(() {
      _likedOverride = !currentLiked;
      _likesOverride = currentLiked ? currentLikes - 1 : currentLikes + 1;
    });
  }

  void _sharePost() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.sharePostReady),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(context.l10n.publication),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_provider.error != null || _provider.post == null) {
              return _DetailError(
                message: _provider.error ?? context.l10n.postNotFound,
                onRetry: _provider.load,
              );
            }

            final post = _provider.post!;
            final type = post.type.option;
            final liked = _likedOverride ?? post.isLiked;
            final likes = _likesOverride ?? post.likesCount;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostAuthorHeader(post: post),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusBadge(isVerified: post.isVerified),
                      _TypeBadge(type: type),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: AppTheme.textNavy,
                      fontSize: 23,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.description,
                    style: const TextStyle(
                      color: Color(0xFF4F5B6B),
                      fontSize: 15.5,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PostMediaViewer(post: post),
                  if (post.mediaUrl != null) const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  PostInteractionBar(
                    likesCount: likes,
                    commentsCount: post.commentsCount,
                    isLiked: liked,
                    onLikeTap: () => _toggleLike(post),
                    onShareTap: _sharePost,
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  CommentsSection(comments: _provider.comments),
                  const SizedBox(height: 8),
                  const CommentInput(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified
        ? const Color(0xFF0B8063)
        : const Color(0xFFFFA000);
    return _Pill(
      icon: isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
      label: isVerified ? context.l10n.verified : context.l10n.inReview,
      color: color,
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final PostTypeOption type;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      icon: type.icon,
      label: type.type.label(context),
      color: type.color,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.mutedText,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
