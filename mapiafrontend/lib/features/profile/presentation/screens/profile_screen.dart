import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
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

  Future<void> _openVerifyPhone() async {
    await Navigator.of(context).pushNamed('/profile/verify-phone');
    if (mounted) {
      _provider.loadProfile();
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
      if (_provider.profile?.phoneVerified != true) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text(
                'Debes verificar tu numero de celular antes de publicar.',
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Verificar',
                onPressed: _openVerifyPhone,
              ),
            ),
          );
        return;
      }
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
    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      bottomNavigationBar: MapiaBottomNavigation(
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

            final reputation = profileReputationInfo(
              postsCount: profile.postsCount,
              likesCount: profile.likesCount,
              followersCount: profile.followersCount,
            );

            return RefreshIndicator(
              onRefresh: _provider.loadProfile,
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
                      isBusy: _provider.isSaving,
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
