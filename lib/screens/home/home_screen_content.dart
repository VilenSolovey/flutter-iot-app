import 'package:flutter/material.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/empty_records_state.dart';
import 'package:my_project/widgets/health_record_card.dart';
import 'package:my_project/widgets/home_app_bar.dart';
import 'package:my_project/widgets/home_iot_metrics_grid.dart';
import 'package:my_project/widgets/mqtt_status_banner.dart';
import 'package:my_project/widgets/section_header.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({
    required this.user,
    required this.records,
    required this.isOnline,
    required this.isMqttConnected,
    required this.heartRate,
    required this.temperature,
    required this.temperatureTopic,
    required this.onAddRecord,
    required this.onEditRecord,
    required this.onDeleteRecord,
    super.key,
  });

  final UserProfile user;
  final List<HealthRecord> records;
  final bool isOnline;
  final bool isMqttConnected;
  final String heartRate;
  final String temperature;
  final String temperatureTopic;
  final VoidCallback onAddRecord;
  final ValueChanged<HealthRecord> onEditRecord;
  final ValueChanged<HealthRecord> onDeleteRecord;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hPad = constraints.maxWidth > 600
            ? constraints.maxWidth * 0.15
            : AppSpacing.lg;
        return CustomScrollView(
          slivers: [
            HomeAppBar(hPad: hPad, fullName: user.fullName, email: user.email),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  MqttStatusBanner(
                    isOnline: isOnline,
                    isMqttConnected: isMqttConnected,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(title: 'Dashboard'),
                  const SizedBox(height: AppSpacing.md),
                  HomeIotMetricsGrid(
                    heartRate: heartRate,
                    isMqttConnected: isMqttConnected,
                    isOnline: isOnline,
                    temperature: temperature,
                    temperatureTopic: temperatureTopic,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: 'Health Journal',
                    action: 'Log +',
                    onAction: onAddRecord,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (records.isEmpty)
                    const EmptyRecordsState()
                  else
                    Column(
                      children: records
                          .map(
                            (record) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: HealthRecordCard(
                                record: record,
                                onEdit: () => onEditRecord(record),
                                onDelete: () => onDeleteRecord(record),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
