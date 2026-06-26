import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/login_screen.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/register_screen.dart';
import 'package:mapiafrontend/features/map/presentation/screens/map_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/create_post_screen.dart';
import 'package:mapiafrontend/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mapiafrontend/features/profile/presentation/screens/profile_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapia',
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/map': (context) => const MapScreen(),
        '/create-post': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/profile/edit': (context) => const EditProfileScreen(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name != null && name.startsWith('/posts/')) {
          final postId = Uri.decodeComponent(name.substring('/posts/'.length));
          if (postId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: postId),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
