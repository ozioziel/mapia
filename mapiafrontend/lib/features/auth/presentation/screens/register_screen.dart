import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_widgets.dart';

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
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _buildUsername(String email) {
    final local = email.split('@').first.toLowerCase();
    final cleaned = local.replaceAll(RegExp(r'[^a-z0-9._]'), '_');
    if (cleaned.length >= 3) return cleaned.substring(0, 40);
    return 'usuario_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  Future<void> _submit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final usernameInput = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final username = usernameInput.isNotEmpty
        ? usernameInput
        : _buildUsername(email);

    String? message;
    if (firstName.isEmpty || lastName.isEmpty) {
      message = 'Nombre y apellido son obligatorios.';
    } else if (username.length < 3 ||
        !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      message =
          'El usuario debe tener 3-40 caracteres (letras, numeros, punto o _).';
    } else if (email.isEmpty || !email.contains('@')) {
      message = 'Ingresa un correo electronico valido.';
    } else if (password.length < 8) {
      message = 'La contrasena debe tener al menos 8 caracteres.';
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
    final auth = AuthScope.of(context);
    final ok = await auth.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      username: username,
      phone: phone.isEmpty ? null : phone,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/map', (_) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error ?? 'No se pudo crear la cuenta.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                SizedBox(height: compact ? 12 * scale : 20 * scale),
                AuthTextField(
                  controller: _firstNameController,
                  hintText: 'Nombre',
                  icon: Icons.person_outline_rounded,
                  iconColor: AppTheme.boliviaGreen,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _lastNameController,
                  hintText: 'Apellido',
                  icon: Icons.badge_outlined,
                  iconColor: AppTheme.boliviaYellow,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _usernameController,
                  hintText: 'Usuario (ej: carla_m)',
                  icon: Icons.alternate_email_rounded,
                  iconColor: AppTheme.primaryBlue,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _phoneController,
                  hintText: 'Telefono (opcional)',
                  icon: Icons.phone_outlined,
                  iconColor: AppTheme.boliviaGreen,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _emailController,
                  hintText: context.l10n.email,
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppTheme.primaryBlue,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _passwordController,
                  hintText: context.l10n.password,
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppTheme.boliviaRed,
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 10 * scale),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: context.l10n.confirmPassword,
                  icon: Icons.verified_user_outlined,
                  iconColor: AppTheme.boliviaYellow,
                  obscureText: true,
                  suffixIcon: Icons.visibility_outlined,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 9 * scale),
                _TermsCheckbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                ),
                SizedBox(height: 12 * scale),
                AuthPrimaryButton(
                  text: _isSubmitting
                      ? 'Creando cuenta...'
                      : context.l10n.signUp,
                  onPressed: _isSubmitting ? null : _submit,
                ),
                SizedBox(height: 12 * scale),
                AuthDivider(text: context.l10n.or),
                SizedBox(height: 10 * scale),
                GoogleAuthButton(
                  text: context.l10n.continueWithGoogle,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Inicio con Google estara disponible pronto.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: compact ? 8 * scale : 14 * scale),
                AuthPenguin(
                  asset: RegisterScreen.penguinAsset,
                  maxHeight: compact ? 88 * scale : 132 * scale,
                  minHeight: 42 * scale,
                ),
                SizedBox(height: compact ? 6 * scale : 10 * scale),
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
