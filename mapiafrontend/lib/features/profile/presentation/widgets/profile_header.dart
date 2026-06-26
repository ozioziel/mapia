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
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppTheme.boliviaRed,
                AppTheme.boliviaYellow,
                AppTheme.boliviaGreen,
              ],
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFFE7F7EF),
            backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
            child: avatarUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: AppTheme.boliviaGreen,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
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
        const SizedBox(height: 10),
        _ContactLine(icon: Icons.mail_outline_rounded, text: profile.email),
        const SizedBox(height: 6),
        _ContactLine(icon: Icons.phone_outlined, text: profile.phone),
        const SizedBox(height: 10),
        _PhoneStatusBadge(isVerified: profile.phoneVerified),
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

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF4F5B6B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4F5B6B),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneStatusBadge extends StatelessWidget {
  const _PhoneStatusBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified
        ? const Color(0xFF0B8063)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.error_outline_rounded,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'Telefono verificado' : 'Telefono no verificado',
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
