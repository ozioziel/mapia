import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/core/localization/time_ago.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';
import 'package:mapiafrontend/features/reputation/presentation/widgets/reputation_badge.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';

class PostsFeedScreen extends StatefulWidget {
  const PostsFeedScreen({super.key, this.focusPostId});

  final String? focusPostId;

  @override
  State<PostsFeedScreen> createState() => _PostsFeedScreenState();
}

class _PostsFeedScreenState extends State<PostsFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<PostEntity> _posts = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocusedPost() {
    final focusPostId = widget.focusPostId;
    if (focusPostId == null || !_scrollController.hasClients) return;

    final index = _posts.indexWhere((post) => post.id == focusPostId);
    if (index < 0) return;

    _scrollController.animateTo(
      (index * 188).toDouble(),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = PostsApi(
        client: createAuthenticatedApiClient(AuthScope.of(context)),
      );
      final posts = await api.fetchPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToFocusedPost(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _openPost(PostEntity post) {
    Navigator.of(context).pushNamed('/posts/${Uri.encodeComponent(post.id)}');
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/map');
      return;
    }
    if (index == 1) return;
    if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/alerts');
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        title: Text(context.l10n.publications),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.boliviaGreen,
            ),
            tooltip: 'Novedades MAPIA',
            onPressed: () => Navigator.of(context).pushNamed('/news-posts'),
          ),
          IconButton(
            icon: const Icon(
              Icons.fact_check_rounded,
              color: AppTheme.primaryBlue,
            ),
            tooltip: 'Candidatos para Alcaldia',
            onPressed: () =>
                Navigator.of(context).pushNamed('/report-candidates'),
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/create-event'),
        backgroundColor: AppTheme.boliviaYellow,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
        icon: const Icon(Icons.event_available_rounded),
        label: const Text('Subir evento'),
      ),
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 1,
        onIndexChanged: _handleNavTap,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _PostsStateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar publicaciones',
        message: _error!,
        actionLabel: context.l10n.retry,
        onAction: _loadPosts,
      );
    }
    if (_posts.isEmpty) {
      return _PostsStateMessage(
        icon: Icons.forum_outlined,
        title: 'Aun no hay publicaciones',
        message:
            'Cuando alguien publique con ubicacion, aparecera aqui y en el mapa.',
        actionLabel: 'Actualizar',
        onAction: _loadPosts,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 108),
        itemCount: _posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _PostFeedItem(
            post: post,
            focused: post.id == widget.focusPostId,
            onTap: () => _openPost(post),
          );
        },
      ),
    );
  }
}

class _PostFeedItem extends StatelessWidget {
  const _PostFeedItem({
    required this.post,
    required this.focused,
    required this.onTap,
  });

  final PostEntity post;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final option = post.type.option;
    final reputation = post.authorReputation == null
        ? authorReputationInfo(post.authorName)
        : reputationInfoFor(score: post.authorReputation, postsCount: 1);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: focused ? option.color : AppTheme.softBorder,
      gradient: focused
          ? LinearGradient(
              colors: [option.color.withValues(alpha: 0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: option.color.withValues(alpha: 0.12),
                  child: Icon(option.icon, color: option.color, size: 23),
                ),
                const SizedBox(width: 11),
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
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${localizedTimeAgo(context, post.createdAt)} - ${post.address ?? context.l10n.laPaz}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ReputationBadge(reputation: reputation, compact: true),
                    ],
                  ),
                ),
                _PostBadge(option: option),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontSize: 18,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              post.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4F5B6B),
                fontSize: 14.2,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.isLiked
                      ? const Color(0xFFE53935)
                      : const Color(0xFF5F6B7A),
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.likesCount}',
                  style: const TextStyle(
                    color: Color(0xFF5F6B7A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF5F6B7A),
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.commentsCount}',
                  style: const TextStyle(
                    color: Color(0xFF5F6B7A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF5F6B7A),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsStateMessage extends StatelessWidget {
  const _PostsStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.mutedText, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _PostBadge extends StatelessWidget {
  const _PostBadge({required this.option});

  final PostTypeOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: option.color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        option.type.label(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: option.color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
