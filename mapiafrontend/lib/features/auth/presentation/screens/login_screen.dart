import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _penguinAsset = 'lib/src/pinguino de chill.png';
  static const String _demoEmail = 'demo@mapia.app';
  static const String _demoPassword = 'mapia123';

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _demoEmail);
    _passwordController = TextEditingController(text: _demoPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == _demoEmail && password == _demoPassword) {
      Navigator.of(context).pushReplacementNamed('/map');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.demoLoginMessage),
        behavior: SnackBarBehavior.floating,
      ),
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
                SizedBox(height: auth.compact ? 26 * scale : 42 * scale),
                AuthTextField(
                  controller: _emailController,
                  hintText: context.l10n.email,
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 22 * scale),
                AuthTextField(
                  controller: _passwordController,
                  hintText: context.l10n.password,
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFEA4335),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 18 * scale),
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
                        color: AppTheme.primaryBlue,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                AuthPrimaryButton(
                  text: context.l10n.signIn,
                  onPressed: _signIn,
                ),
                SizedBox(height: 26 * scale),
                AuthDivider(text: context.l10n.or),
                SizedBox(height: 24 * scale),
                GoogleAuthButton(
                  text: context.l10n.continueWithGoogle,
                  onPressed: _signIn,
                ),
                SizedBox(height: auth.compact ? 26 * scale : 46 * scale),
                Image.asset(
                  _penguinAsset,
                  height: auth.compact ? 210 * scale : 335 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: auth.compact ? 14 * scale : 26 * scale),
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
