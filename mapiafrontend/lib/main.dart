import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:mapiafrontend/features/alerts/presentation/screens/nearby_posts_screen.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/login_screen.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/register_screen.dart';
import 'package:mapiafrontend/features/chatbot/widgets/floating_chatbot_button.dart';
import 'package:mapiafrontend/features/language/presentation/providers/language_provider.dart';
import 'package:mapiafrontend/features/language/presentation/screens/language_settings_screen.dart';
import 'package:mapiafrontend/features/map/presentation/screens/map_screen.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/create_post_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/posts_feed_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/profile_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/verify_phone_screen.dart';
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
          locale: _languageProvider.frameworkLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
          initialRoute: '/map',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/map': (context) => _withExperimentalChatbot(const MapScreen()),
            '/publications': (context) =>
                _withExperimentalChatbot(const PostsFeedScreen()),
            '/create-post': (context) =>
                _withExperimentalChatbot(const CreatePostScreen()),
            '/alerts': (context) =>
                _withExperimentalChatbot(const AlertsScreen()),
            '/profile': (context) =>
                _withExperimentalChatbot(const ProfileScreen()),
            '/profile/edit': (context) =>
                _withExperimentalChatbot(const EditProfileScreen()),
            '/profile/verify-phone': (context) =>
                _withExperimentalChatbot(const VerifyPhoneScreen()),
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
                  builder: (context) => _withExperimentalChatbot(
                    PostDetailScreen(postId: postId),
                  ),
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
                  builder: (context) => _withExperimentalChatbot(
                    PostsFeedScreen(focusPostId: postId),
                  ),
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
                  builder: (context) => _withExperimentalChatbot(
                    NearbyPostsScreen(type: type, radiusKm: radiusKm),
                  ),
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

Widget _withExperimentalChatbot(Widget child) {
  return FloatingChatbotButton(child: child);
}

PostType? _postTypeFromName(String name) {
  for (final type in PostType.values) {
    if (type.name == name) return type;
  }
  return null;
}
