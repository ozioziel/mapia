import 'package:flutter/material.dart';
import 'package:mapiafrontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:mapiafrontend/features/auth/presentation/screens/login_screen.dart';

class AuthScope extends InheritedNotifier<AuthProvider> {
  const AuthScope({super.key, required AuthProvider auth, required super.child})
    : super(notifier: auth);

  static AuthProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in widget tree');
    return scope!.notifier!;
  }
}

class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    return child;
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.auth,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
  });

  final AuthProvider auth;
  final WidgetBuilder authenticatedBuilder;
  final WidgetBuilder unauthenticatedBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _bootstrapScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleBootstrap();
  }

  @override
  void didUpdateWidget(covariant AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auth != widget.auth) {
      _bootstrapScheduled = false;
      _scheduleBootstrap();
    }
  }

  void _scheduleBootstrap() {
    if (_bootstrapScheduled) return;
    _bootstrapScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.auth.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        if (widget.auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (widget.auth.isAuthenticated) {
          return widget.authenticatedBuilder(context);
        }
        return widget.unauthenticatedBuilder(context);
      },
    );
  }
}
