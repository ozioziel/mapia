import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _penguinAsset = 'lib/src/pinguino de chill.png';

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresa un correo electronico valido.');
      return;
    }
    if (password.length < 8) {
      _showError('La contrasena debe tener al menos 8 caracteres.');
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = AuthScope.of(context);
    final ok = await auth.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/map', (_) => false);
      return;
    }

    _showError(auth.error ?? context.l10n.demoLoginMessage);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      children: [
        AuthHeader(
          title: context.l10n.welcomeTitle,
          subtitle: context.l10n.welcomeSubtitle,
        ),
        Builder(
          builder: (context) {
            final auth = AuthScale.of(context);
            final scale = auth.scale;

            return Column(
              children: [
                SizedBox(height: auth.compact ? 18 * scale : 30 * scale),
                AuthTextField(
                  controller: _emailController,
                  hintText: context.l10n.email,
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  controller: _passwordController,
                  hintText: context.l10n.password,
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppTheme.boliviaRed,
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 12 * scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      context.l10n.forgotPassword,
                      style: TextStyle(
                        color: AppTheme.boliviaGreen,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18 * scale),
                AuthPrimaryButton(
                  text: _isSubmitting ? 'Iniciando...' : context.l10n.signIn,
                  onPressed: _isSubmitting ? null : _signIn,
                ),
                SizedBox(height: 18 * scale),
                AuthDivider(text: context.l10n.or),
                SizedBox(height: 16 * scale),
                GoogleAuthButton(
                  text: context.l10n.continueWithGoogle,
                  onPressed: () {
                    _showError('Inicio con Google estara disponible pronto.');
                  },
                ),
                SizedBox(height: auth.compact ? 14 * scale : 24 * scale),
                AuthPenguin(
                  asset: _penguinAsset,
                  maxHeight: auth.compact ? 132 * scale : 210 * scale,
                  minHeight: 58 * scale,
                ),
                SizedBox(height: auth.compact ? 8 * scale : 14 * scale),
                AuthBottomLink(
                  text: context.l10n.dontHaveAccount,
                  actionText: context.l10n.signUp,
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
