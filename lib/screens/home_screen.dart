import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/iot_metric_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.15
                : AppSpacing.lg;
            return CustomScrollView(
              slivers: [
                _AppBar(hPad: hPad),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),
                      const SectionHeader(title: 'Dashboard'),
                      const SizedBox(height: AppSpacing.md),
                      const _IotMetricsGrid(),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(title: 'Device Status'),
                      const SizedBox(height: AppSpacing.md),
                      const _DeviceStatusCard(),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.hPad});
  final double hPad;

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
                Text('Good morning,', style: AppText.muted),
                const Text('Vilen', style: AppText.h2),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Hero(
                tag: 'profile-avatar',
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.card,
                  child:
                      Icon(Icons.person, color: AppColors.secondary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IotMetricsGrid extends StatelessWidget {
  const _IotMetricsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.2,
      children: const [
        IotMetricCard(
          icon: Icons.favorite,
          label: 'Heart Rate',
          value: '72',
          unit: 'bpm',
          color: Color(0xFFE91E63),
          isPulsing: true,
          delay: Duration(milliseconds: 0),
        ),
        IotMetricCard(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: '36.6',
          unit: '°C',
          color: Color(0xFFFF9800),
          delay: Duration(milliseconds: 100),
        ),
        IotMetricCard(
          icon: Icons.air,
          label: 'SpO2',
          value: '98',
          unit: '%',
          color: Color(0xFF00BCD4),
          delay: Duration(milliseconds: 200),
        ),
        IotMetricCard(
          icon: Icons.directions_walk,
          label: 'Steps',
          value: '4200',
          unit: 'steps',
          color: Color(0xFF4CAF50),
          delay: Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _DeviceStatusCard extends StatelessWidget {
  const _DeviceStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.watch,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VITA Watch Pro',
                  style: AppText.body,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Connected',
                      style: AppText.muted.copyWith(
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Battery: 85%',
            style: AppText.muted,
          ),
        ],
      ),
    );
  }
}
