import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/core/localization/time_ago.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/posts/data/datasources/mock_posts_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostsFeedScreen extends StatefulWidget {
  const PostsFeedScreen({super.key, this.focusPostId});

  final String? focusPostId;

  @override
  State<PostsFeedScreen> createState() => _PostsFeedScreenState();
}

class _PostsFeedScreenState extends State<PostsFeedScreen> {
  final List<PostEntity> _posts = const MockPostsDatasource().getPosts();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocusedPost());
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
      Navigator.of(context).pushNamed('/create-post');
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/alerts');
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.sectionReady),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(context.l10n.publications),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      body: ListView.separated(
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
      bottomNavigationBar: _PostsBottomNavigation(
        currentIndex: 1,
        onIndexChanged: _handleNavTap,
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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: focused ? option.color : const Color(0xFFE4EAF0),
              width: focused ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: focused ? 0.12 : 0.06),
                blurRadius: focused ? 18 : 10,
                offset: const Offset(0, 7),
              ),
            ],
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

class _PostsBottomNavigation extends StatelessWidget {
  const _PostsBottomNavigation({
    required this.currentIndex,
    required this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(
        context.l10n.map,
        Icons.map_rounded,
        const Color(0xFFE53935),
      ),
      _NavItemData(
        context.l10n.explore,
        Icons.travel_explore_rounded,
        const Color(0xFFE53935),
      ),
      _NavItemData(
        context.l10n.publish,
        Icons.add_rounded,
        const Color(0xFFFFB300),
      ),
      _NavItemData(
        context.l10n.alerts,
        Icons.notifications_none_rounded,
        const Color(0xFF0B8063),
      ),
      _NavItemData(
        context.l10n.profile,
        Icons.person_outline_rounded,
        const Color(0xFF0B8063),
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Expanded(child: _BoliviaStripe(color: Color(0xFFE53935))),
                Expanded(child: _BoliviaStripe(color: Color(0xFFFFC107))),
                Expanded(child: _BoliviaStripe(color: Color(0xFF0B9E59))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _BottomNavButton(
                      data: items[i],
                      active: currentIndex == i,
                      prominent: i == 2,
                      onTap: () => onIndexChanged(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BoliviaStripe extends StatelessWidget {
  const _BoliviaStripe({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: 3, color: color);
  }
}

class _NavItemData {
  const _NavItemData(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.data,
    required this.active,
    required this.prominent,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final bool prominent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.fromLTRB(2, prominent ? 0 : 3, 2, 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prominent)
              Transform.translate(
                offset: const Offset(0, -10),
                child: const _PublishCircle(),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 34,
                decoration: BoxDecoration(
                  color: active
                      ? data.color.withValues(alpha: 0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  data.icon,
                  color: active ? data.color : const Color(0xFF5F6B7A),
                  size: 22,
                ),
              ),
            SizedBox(height: prominent ? 0 : 2),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? data.color : const Color(0xFF5F6B7A),
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishCircle extends StatelessWidget {
  const _PublishCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFB300),
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.38),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
    );
  }
}
