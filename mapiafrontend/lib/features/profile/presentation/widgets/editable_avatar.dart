import 'package:flutter/material.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.onTap,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? 'M'
        : name.trim().characters.first.toUpperCase();

    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(60),
        child: SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFE7F7EF),
                  backgroundImage: avatarUrl == null
                      ? null
                      : NetworkImage(avatarUrl!),
                  child: avatarUrl == null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            color: Color(0xFF0B8063),
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 4,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
