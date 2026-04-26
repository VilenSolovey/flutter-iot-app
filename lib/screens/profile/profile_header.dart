import 'package:flutter/material.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final avatarText =
        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';
    return Row(
      children: [
        Hero(
          tag: 'profile-avatar',
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: AppText.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(user.email, style: AppText.muted),
            ],
          ),
        ),
      ],
    );
  }
}
