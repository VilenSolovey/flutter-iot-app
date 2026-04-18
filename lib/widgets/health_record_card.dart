import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/theme/app_theme.dart';

class HealthRecordCard extends StatelessWidget {
  const HealthRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final HealthRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Water Intake':
        return Icons.water_drop;
      case 'Weight':
        return Icons.monitor_weight;
      case 'Blood Pressure':
        return Icons.favorite;
      case 'Blood Sugar':
        return Icons.bloodtype;
      case 'Sleep':
        return Icons.bedtime;
      case 'Calories':
        return Icons.local_fire_department;
      default:
        return Icons.health_and_safety;
    }
  }

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
          CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            child: Icon(_getIconForType(record.type), color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.type, style: AppText.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${record.value} ${record.unit}',
                  style: AppText.h2.copyWith(fontSize: 18),
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(record.timestamp),
                  style: AppText.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: AppColors.secondary),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
