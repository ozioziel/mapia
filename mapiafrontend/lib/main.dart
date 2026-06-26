import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:mapiafrontend/features/alerts/presentation/screens/nearby_posts_screen.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/login_screen.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/register_screen.dart';
import 'package:mapiafrontend/features/language/presentation/providers/language_provider.dart';
import 'package:mapiafrontend/features/language/presentation/screens/language_settings_screen.dart';
import 'package:mapiafrontend/features/map/presentation/screens/map_screen.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/create_post_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/posts_feed_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/profile_screen.dart';
import 'package:mapiafrontend/l10n/app_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final LanguageProvider _languageProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = LanguageProvider()..load();
  }

  @override
  void dispose() {
    _languageProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mapia',
          theme: AppTheme.light,
          locale: _languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/map': (context) => const MapScreen(),
            '/publications': (context) => const PostsFeedScreen(),
            '/create-post': (context) => const CreatePostScreen(),
            '/alerts': (context) => const AlertsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/profile/edit': (context) => const EditProfileScreen(),
            '/language': (context) =>
                LanguageSettingsScreen(provider: _languageProvider),
          },
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          onGenerateRoute: (settings) {
            final name = settings.name;
            if (name != null && name.startsWith('/posts/')) {
              final postId = Uri.decodeComponent(
                name.substring('/posts/'.length),
              );
              if (postId.isNotEmpty) {
                return MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: postId),
                  settings: settings,
                );
              }
            }
            if (name != null && name.startsWith('/publications/')) {
              final postId = Uri.decodeComponent(
                name.substring('/publications/'.length),
              );
              if (postId.isNotEmpty) {
                return MaterialPageRoute(
                  builder: (context) => PostsFeedScreen(focusPostId: postId),
                  settings: settings,
                );
              }
            }
            if (name != null && name.startsWith('/alerts/posts/')) {
              final uri = Uri.parse(name);
              final typeName = uri.pathSegments.length >= 3
                  ? uri.pathSegments[2]
                  : '';
              final type = _postTypeFromName(typeName);
              final radiusKm = double.tryParse(
                uri.queryParameters['radiusKm'] ?? '',
              );

              if (type != null && radiusKm != null) {
                return MaterialPageRoute(
                  builder: (context) =>
                      NearbyPostsScreen(type: type, radiusKm: radiusKm),
                  settings: settings,
                );
              }
            }
            return null;
          },
        );
      },
    );
  }
}

PostType? _postTypeFromName(String name) {
  for (final type in PostType.values) {
    if (type.name == name) return type;
  }
  return null;
}
