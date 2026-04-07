import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';

class MqttStatusBanner extends StatelessWidget {
  const MqttStatusBanner({
    required this.isOnline,
    required this.isMqttConnected,
    super.key,
  });

  final bool isOnline;
  final bool isMqttConnected;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color accentColor;
    final IconData icon;
    final String title;
    final String subtitle;

    if (!isOnline) {
      backgroundColor = const Color(0xFF3A2020);
      accentColor = const Color(0xFFFF8A80);
      icon = Icons.wifi_off;
      title = 'Офлайн режим';
      subtitle = 'Сесія збережена, але мережа і MQTT зараз недоступні.';
    } else if (!isMqttConnected) {
      backgroundColor = const Color(0xFF3B321D);
      accentColor = const Color(0xFFFFD54F);
      icon = Icons.sync_problem;
      title = 'MQTT недоступний';
      subtitle = 'Інтернет є, але підключення до брокера ще не встановлено.';
    } else {
      backgroundColor = const Color(0xFF173123);
      accentColor = const Color(0xFF81C784);
      icon = Icons.sensors;
      title = 'MQTT активний';
      subtitle = 'Дані з датчика оновлюються в реальному часі.';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppText.muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
