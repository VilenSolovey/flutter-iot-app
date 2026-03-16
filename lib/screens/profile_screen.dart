import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: AppText.h2),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: AppColors.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = constraints.maxWidth > 600
              ? constraints.maxWidth * 0.15
              : AppSpacing.lg;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(),
                const SizedBox(height: AppSpacing.xl),
                const _StatsRow(),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Connected Device'),
                const SizedBox(height: AppSpacing.md),
                const _ConnectedDeviceCard(),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: 'Recent Activity', action: 'History'),
                const SizedBox(height: AppSpacing.md),
                const _RecentWorkouts(),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Logout',
                  isOutlined: true,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
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
              const Text('Vilen', style: AppText.h2),
              const SizedBox(height: AppSpacing.xs),
              Text('vilen@gmail.com', style: AppText.muted),
              const SizedBox(height: AppSpacing.sm),
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
                    'Device Connected',
                    style: AppText.label.copyWith(
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        StatCard(value: '99%', label: 'UPTIME'),
        SizedBox(width: AppSpacing.sm),
        StatCard(value: '3', label: 'DEVICES'),
        SizedBox(width: AppSpacing.sm),
        StatCard(value: '24/7', label: 'MONITORING'),
      ],
    );
  }
}

class _RecentWorkouts extends StatelessWidget {
  const _RecentWorkouts();

  static const _recent = [
    ('Heart Rate Spike', 'Alert', '2h', 'ago'),
    ('Device Sync', 'Status', '5h', 'ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _recent
          .map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: WorkoutCard(
                title: w.$1,
                category: w.$2,
                duration: w.$3,
                calories: w.$4,
                fullWidth: true,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ConnectedDeviceCard extends StatelessWidget {
  const _ConnectedDeviceCard();

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.watch,
              color: AppColors.accent,
              size: 28,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.battery_charging_full,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '85%',
                style: AppText.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
