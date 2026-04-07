import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.hPad,
    required this.fullName,
    required this.email,
    super.key,
  });

  final double hPad;
  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(hPad, AppSpacing.lg, hPad, AppSpacing.md),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email, style: AppText.muted),
                Text(fullName, style: AppText.h2),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: const Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.card,
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
