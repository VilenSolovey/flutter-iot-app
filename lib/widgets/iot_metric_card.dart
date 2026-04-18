import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class IotMetricCard extends StatefulWidget {
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
  State<IotMetricCard> createState() => _IotMetricCardState();
}

class _IotMetricCardState extends State<IotMetricCard> {
  var _isVisible = false;

  @override
  void initState() {
    super.initState();
    _startEntranceAnimation();
  }

  Future<void> _startEntranceAnimation() async {
    await Future<void>.delayed(widget.delay);
    if (!mounted) {
      return;
    }

    setState(() {
      _isVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _isVisible ? 1 : 0),
      duration: const Duration(milliseconds: 500),
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
                if (widget.isPulsing)
                  _PulsingIcon(
                    icon: widget.icon,
                    color: widget.color ?? AppColors.accent,
                  )
                else
                  Icon(
                    widget.icon,
                    color: widget.color ?? AppColors.accent,
                    size: 24,
                  ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.label,
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
                    widget.value,
                    key: ValueKey(widget.value),
                    style: AppText.h1.copyWith(
                      color: widget.color ?? AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.unit,
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

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: 24,
      ),
    );
  }
}
