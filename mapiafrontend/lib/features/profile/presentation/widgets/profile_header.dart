import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
    final initial = profile.name.trim().isEmpty
        ? 'M'
        : profile.name.trim().characters.first.toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: const Color(0xFFE7F7EF),
          backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
          child: avatarUrl == null
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF0B8063),
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),
        Text(
          profile.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textNavy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        if ((profile.bio ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            profile.bio!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4F5B6B),
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
