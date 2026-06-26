import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
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
        AuthHeader(
          title: context.l10n.createAccountTitle,
          subtitle: context.l10n.createAccountSubtitle,
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
                AuthTextField(
                  hintText: context.l10n.fullName,
                  icon: Icons.person_outline_rounded,
                  iconColor: Color(0xFF34A853),
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  hintText: context.l10n.email,
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  hintText: context.l10n.password,
                  icon: Icons.lock_outline_rounded,
                  iconColor: Color(0xFFEA4335),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  hintText: context.l10n.confirmPassword,
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
                AuthPrimaryButton(text: context.l10n.signUp),
                SizedBox(height: 22 * scale),
                AuthDivider(text: context.l10n.or),
                SizedBox(height: 20 * scale),
                GoogleAuthButton(text: context.l10n.continueWithGoogle),
                SizedBox(height: compact ? 18 * scale : 28 * scale),
                Image.asset(
                  RegisterScreen.penguinAsset,
                  height: compact ? 180 * scale : 250 * scale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: compact ? 10 * scale : 18 * scale),
                AuthBottomLink(
                  text: context.l10n.alreadyHaveAccount,
                  actionText: context.l10n.signIn,
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
    final l10n = context.l10n;

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
              text: l10n.termsAgreementPrefix,
              children: [
                TextSpan(
                  text: l10n.terms,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: l10n.termsAgreementMiddle),
                TextSpan(
                  text: l10n.privacyPolicy,
                  style: const TextStyle(
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
