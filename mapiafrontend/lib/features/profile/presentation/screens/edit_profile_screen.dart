import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';
import 'package:mapiafrontend/features/profile/presentation/widgets/editable_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileProvider _provider;
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  String? _avatarUrl;
  bool _formReady = false;

  @override
  void initState() {
    super.initState();
    _provider = EditProfileProvider()..loadProfile();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _provider.addListener(_syncProfileOnce);
  }

  @override
  void dispose() {
    _provider.removeListener(_syncProfileOnce);
    _provider.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _syncProfileOnce() {
    final profile = _provider.profile;
    if (_formReady || profile == null) return;
    _nameController.text = profile.name;
    _usernameController.text = profile.username;
    _bioController.text = profile.bio ?? '';
    _avatarUrl = profile.avatarUrl;
    _formReady = true;
    setState(() {});
  }

  void _simulatePhotoSelection() {
    setState(() {
      _avatarUrl =
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240';
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.simulatedPhotoReady),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.nameAndUsernameRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ok = await _provider.updateProfile(
      name: name,
      username: username,
      bio: _bioController.text,
      avatarUrl: _avatarUrl,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider.error ?? context.l10n.couldNotSaveChanges),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textNavy,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, _) {
            if (_provider.isLoading && _provider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_provider.error != null && _provider.profile == null) {
              return _EditProfileError(
                message: _provider.error!,
                onRetry: _provider.loadProfile,
              );
            }

            final profile = _provider.profile;
            if (profile == null || !_formReady) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: EditableAvatar(
                      name: _nameController.text,
                      avatarUrl: _avatarUrl,
                      onTap: _simulatePhotoSelection,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _provider.isSaving
                        ? null
                        : _simulatePhotoSelection,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.l10n.changePhoto),
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(
                    controller: _nameController,
                    label: context.l10n.name,
                    icon: Icons.badge_outlined,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _ProfileTextField(
                    controller: _usernameController,
                    label: context.l10n.username,
                    icon: Icons.alternate_email_rounded,
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
                    onPressed: _provider.isSaving ? null : _save,
                    icon: _provider.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(context.l10n.saveChanges),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B8063),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _provider.isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(context.l10n.cancel),
                  ),
                ],
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
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4EAF1)),
        ),
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
