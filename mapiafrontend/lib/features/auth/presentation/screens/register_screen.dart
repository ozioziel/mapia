import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String penguinAsset = 'lib/src/pinguino registrandose.png';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = true;

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      compactCard: true,
      children: [
        const AuthHeader(
          title: 'Create Mapia account',
          subtitle: 'Join and report what is happening nearby.',
          titleScale: 0.92,
        ),
        Builder(
          builder: (context) {
            final auth = AuthScale.of(context);
            final scale = auth.scale;
            final compact = auth.compact;

            return Column(
              children: [
                SizedBox(height: compact ? 20 * scale : 30 * scale),
                const AuthTextField(
                  hintText: 'Full name',
                  icon: Icons.person_outline_rounded,
                  iconColor: Color(0xFF34A853),
                ),
                SizedBox(height: 16 * scale),
                const AuthTextField(
                  hintText: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                ),
                SizedBox(height: 16 * scale),
                const AuthTextField(
                  hintText: 'Password',
                  icon: Icons.lock_outline_rounded,
                  iconColor: Color(0xFFEA4335),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                ),
                SizedBox(height: 16 * scale),
                const AuthTextField(
                  hintText: 'Confirm password',
                  icon: Icons.verified_user_outlined,
                  iconColor: Color(0xFFFBBC05),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                ),
                SizedBox(height: 14 * scale),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                ),
                SizedBox(height: 18 * scale),
                const AuthPrimaryButton(text: 'Create account'),
                SizedBox(height: 22 * scale),
                const AuthDivider(),
                SizedBox(height: 20 * scale),
                const GoogleAuthButton(text: 'Continue with Google'),
                SizedBox(height: compact ? 18 * scale : 28 * scale),
                Image.asset(
                  RegisterScreen.penguinAsset,
                  height: compact ? 180 * scale : 250 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: compact ? 10 * scale : 18 * scale),
                AuthBottomLink(
                  text: 'Already have an account?',
                  actionText: 'Sign in',
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    } else {
                      navigator.pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scale = AuthScale.of(context).scale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 26 * scale,
          height: 26 * scale,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
            side: const BorderSide(color: AppTheme.softBorder, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5 * scale),
            ),
          ),
        ),
        SizedBox(width: 10 * scale),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              children: const [
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12.5 * scale,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
