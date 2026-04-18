import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class EmptyRecordsState extends StatelessWidget {
  const EmptyRecordsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Натисни + щоб додати перший запис',
        style: AppText.muted,
      ),
    );
  }
}
