import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_header.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_stats.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/user_posts_grid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ProfileProvider()..loadProfile();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).pushNamed('/profile/edit');
    if (mounted) {
      _provider.loadProfile();
    }
  }

  Future<void> _openLanguageSettings() async {
    await Navigator.of(context).pushNamed('/language');
  }

  void _openPost(ProfilePostEntity post) {
    Navigator.of(context).pushNamed('/posts/${Uri.encodeComponent(post.id)}');
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.logoutQuestion),
          content: Text(context.l10n.logoutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: Text(context.l10n.logout),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final ok = await _provider.logout();
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider.error ?? context.l10n.couldNotLogout),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/map');
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/publications');
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed('/create-post');
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/alerts');
      return;
    }
    if (index == 4) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.sectionReady),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(context.l10n.profile),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      bottomNavigationBar: _ProfileBottomNavigation(
        currentIndex: 4,
        onIndexChanged: _onBottomNavTap,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_provider.error != null && _provider.profile == null) {
              return _ProfileError(
                message: _provider.error!,
                onRetry: _provider.loadProfile,
              );
            }

            final profile = _provider.profile;
            if (profile == null) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              onRefresh: _provider.loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(profile: profile),
                    const SizedBox(height: 18),
                    ProfileStats(
                      postsCount: profile.postsCount,
                      followersCount: profile.followersCount,
                      followingCount: profile.followingCount,
                      likesCount: profile.likesCount,
                    ),
                    const SizedBox(height: 14),
                    ProfileActionButtons(
                      isBusy: _provider.isSaving,
                      onEdit: _openEditProfile,
                      onLanguage: _openLanguageSettings,
                      onLogout: _confirmLogout,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.myPosts,
                      style: const TextStyle(
                        color: AppTheme.textNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    UserPostsGrid(posts: profile.posts, onPostTap: _openPost),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

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

class _ProfileBottomNavigation extends StatelessWidget {
  const _ProfileBottomNavigation({
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
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
            const Row(
              children: [
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
                child: _PublishCircle(data: data),
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
  const _PublishCircle({required this.data});

  final _NavItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
    );
  }
}
