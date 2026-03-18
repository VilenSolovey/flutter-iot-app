import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.title,
    required this.category,
    required this.duration,
    required this.calories,
    super.key,
    this.isFeatured = false,
    this.fullWidth = false,
  });

  final String title;
  final String category;
  final String duration;
  final String calories;
  final bool isFeatured;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    if (isFeatured) return _FeaturedCard(this);
    return _CompactCard(this);
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard(this.data);
  final WorkoutCard data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(label: data.category, onAccent: true),
          const SizedBox(height: AppSpacing.sm),
          Text(data.title, style: AppText.h1.copyWith(color: AppColors.bg)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Pill(label: '${data.duration} min', dark: true),
              const SizedBox(width: AppSpacing.sm),
              _Pill(label: '${data.calories} kcal', dark: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard(this.data);
  final WorkoutCard data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: data.fullWidth ? double.infinity : 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tag(label: data.category),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.title,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Pill(label: '${data.duration} min'),
              const SizedBox(width: AppSpacing.xs),
              _Pill(label: '${data.calories} kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.onAccent = false});
  final String label;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppText.label.copyWith(
        color: onAccent ? AppColors.bg.withValues(alpha: 0.6) : null,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.dark = false});
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? AppColors.bg.withValues(alpha: 0.2) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppText.muted.copyWith(
          fontSize: 12,
          color: dark ? AppColors.bg : AppColors.secondary,
        ),
      ),
    );
  }
}
