import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider_factory.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_header.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/profile_stats.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/user_posts_grid.dart';
import 'package:mapiafrontend/features/reputation/domain/reputation_helper.dart';
import 'package:mapiafrontend/features/reputation/presentation/widgets/reputation_summary_card.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileProvider? _provider;
  String? _activeUserId;

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  void _ensureProvider() {
    final userId = AuthScope.of(context).user?.id;
    if (userId == null || userId == _activeUserId) return;

    _provider?.dispose();
    _activeUserId = userId;
    _provider = createProfileProvider(context)..loadProfile();
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).pushNamed('/profile/edit');
    if (mounted) {
      _provider?.loadProfile();
    }
  }

  Future<void> _openLanguageSettings() async {
    await Navigator.of(context).pushNamed('/language');
  }

  Future<void> _openVerifyPhone() async {
    await Navigator.of(context).pushNamed('/profile/verify-phone');
    if (mounted) {
      _provider?.loadProfile();
    }
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

    await AuthScope.of(context).logout();
    if (!mounted) return;
    setState(() {
      _activeUserId = null;
      _provider?.dispose();
      _provider = null;
    });
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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
      Navigator.of(context).pushReplacementNamed('/alerts');
      return;
    }
    if (index == 3) return;
  }

  @override
  Widget build(BuildContext context) {
    _ensureProvider();
    final provider = _provider;

    if (provider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 3,
        onIndexChanged: _onBottomNavTap,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: provider,
          builder: (context, _) {
            if (provider.isLoading && provider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.profile == null) {
              return _ProfileError(
                message: provider.error!,
                onRetry: provider.loadProfile,
              );
            }

            final profile = provider.profile;
            if (profile == null) {
              return const SizedBox.shrink();
            }

            final reputation = reputationInfoFor(
              score: profile.reputationScore,
              postsCount: profile.postsCount,
            );

            return RefreshIndicator(
              onRefresh: provider.loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      gradient: AppTheme.profileGradient,
                      child: ProfileHeader(profile: profile),
                    ),
                    const SizedBox(height: 18),
                    ProfileStats(
                      postsCount: profile.postsCount,
                      followersCount: profile.followersCount,
                      followingCount: profile.followingCount,
                      likesCount: profile.likesCount,
                    ),
                    const SizedBox(height: 14),
                    ReputationSummaryCard(reputation: reputation),
                    const SizedBox(height: 14),
                    ProfileActionButtons(
                      isBusy: provider.isSaving,
                      phoneVerified: profile.phoneVerified,
                      onEdit: _openEditProfile,
                      onVerifyPhone: _openVerifyPhone,
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
