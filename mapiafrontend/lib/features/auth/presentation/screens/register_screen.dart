import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String penguinAsset = 'lib/src/pinguino registrandose.png';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = true;
  bool _isSubmitting = false;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? message;
    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      message = 'Nombre, apellido y telefono son obligatorios.';
    } else if (!_isValidPhone(phone)) {
      message = 'Ingresa un telefono valido.';
    } else if (email.isEmpty || !email.contains('@')) {
      message = 'Ingresa un correo electronico valido.';
    } else if (password.length < 6) {
      message = 'La contrasena debe tener al menos 6 caracteres.';
    } else if (password != confirmPassword) {
      message = 'Las contrasenas no coinciden.';
    } else if (!_acceptedTerms) {
      message = 'Debes aceptar los terminos para crear tu cuenta.';
    }

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await ProfileMockDatasource().registerProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushReplacementNamed('/map');
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9 ]{7,15}$').hasMatch(phone);
  }

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
                  controller: _firstNameController,
                  hintText: 'Nombre',
                  icon: Icons.person_outline_rounded,
                  iconColor: Color(0xFF34A853),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  controller: _lastNameController,
                  hintText: 'Apellido',
                  icon: Icons.badge_outlined,
                  iconColor: Color(0xFFFBBC05),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  controller: _phoneController,
                  hintText: 'Telefono',
                  icon: Icons.phone_outlined,
                  iconColor: Color(0xFF0B8063),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
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
                  iconColor: Color(0xFFEA4335),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 16 * scale),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: context.l10n.confirmPassword,
                  icon: Icons.verified_user_outlined,
                  iconColor: Color(0xFFFBBC05),
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 14 * scale),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                ),
                SizedBox(height: 18 * scale),
                AuthPrimaryButton(
                  text: _isSubmitting
                      ? 'Creando cuenta...'
                      : context.l10n.signUp,
                  onPressed: _isSubmitting ? null : _submit,
                ),
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
