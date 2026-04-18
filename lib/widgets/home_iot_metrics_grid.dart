import 'package:flutter/material.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/iot_metric_card.dart';

class HomeIotMetricsGrid extends StatelessWidget {
  const HomeIotMetricsGrid({
    required this.heartRate,
    required this.isMqttConnected,
    required this.isOnline,
    required this.temperature,
    required this.temperatureTopic,
    super.key,
  });

  final String heartRate;
  final bool isMqttConnected;
  final bool isOnline;
  final String temperature;
  final String temperatureTopic;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      children: [
        IotMetricCard(
          icon: Icons.favorite,
          label: 'Heart Rate',
          value: heartRate,
          unit: 'bpm',
          color: const Color(0xFFE91E63),
          isPulsing: true,
        ),
        IotMetricCard(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: temperature,
          unit: '°C',
          color: const Color(0xFFFF9800),
          delay: const Duration(milliseconds: 100),
        ),
        IotMetricCard(
          icon: Icons.hub,
          label: 'MQTT',
          value: isMqttConnected ? 'LIVE' : 'OFF',
          unit: '',
          color: const Color(0xFF00BCD4),
          delay: const Duration(milliseconds: 200),
        ),
        IotMetricCard(
          icon: Icons.wifi,
          label: isOnline ? 'Network' : temperatureTopic,
          value: isOnline ? 'ONLINE' : 'OFFLINE',
          unit: '',
          color: const Color(0xFF4CAF50),
          delay: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
