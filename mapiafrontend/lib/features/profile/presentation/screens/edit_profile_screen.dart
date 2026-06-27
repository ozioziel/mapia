import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_api.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider_factory.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/editable_avatar.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  EditProfileProvider? _provider;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  String? _avatarUrl;
  bool _formReady = false;
  final _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_provider == null) {
      _provider = createProfileProvider(context)..loadProfile();
      _provider!.addListener(_syncProfileOnce);
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _provider?.removeListener(_syncProfileOnce);
    _provider?.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _syncProfileOnce() {
    final profile = _provider?.profile;
    if (_formReady || profile == null) return;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _bioController.text = profile.bio ?? '';
    _avatarUrl = profile.avatarUrl;
    _formReady = true;
    setState(() {});
  }

  Future<void> _pickAndUploadAvatar() async {
    final auth = AuthScope.of(context);
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 86,
    );
    if (image == null) return;

    try {
      final api = ProfileApi(client: createAuthenticatedApiClient(auth));
      final profile = await api.uploadAvatar(image);
      if (!mounted) return;
      setState(() => _avatarUrl = profile['avatarUrl'] as String?);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('No se pudo subir la foto: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre, apellido y telefono son obligatorios.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un telefono valido.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ok = await _provider!.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      bio: _bioController.text,
      avatarUrl: _avatarUrl,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider!.error ?? context.l10n.couldNotSaveChanges),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9 ]{7,15}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return AppGradientScaffold(
        appBar: AppBar(title: Text(context.l10n.editProfile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.editProfile)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: provider,
          builder: (context, _) {
            if (provider.isLoading && provider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.profile == null) {
              return _EditProfileError(
                message: provider.error!,
                onRetry: provider.loadProfile,
              );
            }

            final profile = provider.profile;
            if (profile == null || !_formReady) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              child: AppCard(
                padding: const EdgeInsets.all(18),
                gradient: AppTheme.mintGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: EditableAvatar(
                        name: _firstNameController.text,
                        avatarUrl: _avatarUrl,
                        onTap: _pickAndUploadAvatar,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: provider.isSaving
                          ? null
                          : _pickAndUploadAvatar,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(context.l10n.changePhoto),
                    ),
                    const SizedBox(height: 16),
                    _ProfileTextField(
                      controller: _firstNameController,
                      label: 'Nombre',
                      icon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _ProfileTextField(
                      controller: _lastNameController,
                      label: 'Apellido',
                      icon: Icons.badge_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    _ProfileTextField(
                      controller: _phoneController,
                      label: 'Telefono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    _ProfileTextField(
                      controller: _bioController,
                      label: context.l10n.bio,
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: provider.isSaving ? null : _save,
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(context.l10n.saveChanges),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(context.l10n.cancel),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _EditProfileError extends StatelessWidget {
  const _EditProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.mutedText,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
