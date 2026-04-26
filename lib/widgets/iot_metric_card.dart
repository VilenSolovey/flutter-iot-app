import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/pulsing_icon.dart';

class IotMetricCard extends StatelessWidget {
  const IotMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    super.key,
    this.color,
    this.isPulsing = false,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color? color;
  final bool isPulsing;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPulsing)
                  PulsingIcon(
                    icon: icon,
                    color: color ?? AppColors.accent,
                  )
                else
                  Icon(
                    icon,
                    color: color ?? AppColors.accent,
                    size: 24,
                  ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.muted,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: AppText.h1.copyWith(
                      color: color ?? AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: AppText.muted.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
