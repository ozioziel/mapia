import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider_factory.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  ProfileProvider? _provider;
  late final TextEditingController _codeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider ??= createProfileProvider(context)..loadProfile();
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _provider?.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final provider = _provider;
    if (provider == null) return;

    final sent = await provider.sendPhoneVerificationCode();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Codigo enviado. Revisa tu telefono o el log del backend en desarrollo.'
              : (provider.error ?? 'No pudimos enviar el codigo.'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verifyCode() async {
    final provider = _provider;
    if (provider == null) return;

    final ok = await provider.verifyPhoneCode(_codeController.text);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Telefono verificado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Codigo invalido o expirado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return AppGradientScaffold(
        appBar: AppBar(title: const Text('Verificar telefono')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Verificar telefono')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: provider,
          builder: (context, _) {
            final profile = provider.profile;

            if (provider.isLoading && profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profile == null) return const SizedBox.shrink();

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(20),
                  gradient: AppTheme.warmGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.sms_outlined,
                        color: Color(0xFF0B8063),
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.phone,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.phoneVerified
                            ? 'Tu telefono ya esta verificado.'
                            : 'Solicita un codigo e ingresalo para habilitar publicaciones.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed:
                            provider.isSendingCode || profile.phoneVerified
                            ? null
                            : _sendCode,
                        icon: provider.isSendingCode
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_to_mobile_outlined),
                        label: const Text('Enviar codigo'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        enabled: !profile.phoneVerified,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Codigo OTP',
                          prefixIcon: Icon(Icons.password_rounded),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed:
                            provider.isVerifyingCode || profile.phoneVerified
                            ? null
                            : _verifyCode,
                        icon: provider.isVerifyingCode
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.verified_user_outlined),
                        label: const Text('Verificar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.boliviaGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
