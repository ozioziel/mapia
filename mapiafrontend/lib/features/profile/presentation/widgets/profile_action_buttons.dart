import 'package:flutter/material.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.onEdit,
    required this.onLogout,
    this.isBusy = false,
  });

  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar perfil'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: isBusy ? null : onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesion'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE53935),
            minimumSize: const Size.fromHeight(46),
            side: const BorderSide(color: Color(0xFFE53935)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
