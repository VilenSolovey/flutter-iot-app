import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/iot_metric_card.dart';
import 'package:my_project/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.authService,
    required this.healthRecordService,
    super.key,
  });

  final AuthService authService;
  final HealthRecordService healthRecordService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _user;
  List<HealthRecord> _records = <HealthRecord>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await widget.authService.getActiveUser();
    if (user == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final records = await widget.healthRecordService.getRecords();
    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _showRecordDialog({HealthRecord? record}) async {
    final formKey = GlobalKey<FormState>();
    final types = HealthRecordService.allowedMetrics.keys.toList();
    var selectedType = record?.type ?? types.first;
    final valueController = TextEditingController(text: record?.value ?? '');

    final action = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                record == null ? 'Add Vital Sign' : 'Edit Vital Sign',
                style: AppText.h2,
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Metric Type', style: AppText.label),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: AppColors.card,
                      style: AppText.body,
                      items: types.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedType = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: valueController,
                      style: AppText.body,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Value',
                        hintText: 'e.g. 75',
                        suffixText:
                            HealthRecordService.allowedMetrics[selectedType],
                        suffixStyle: AppText.muted,
                      ),
                      validator: (value) =>
                          widget.healthRecordService.validateValue(value ?? ''),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    Navigator.pop(context, true);
                  },
                  child: Text(record == null ? 'Save' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (action != true) {
      valueController.dispose();
      return;
    }

    final value = valueController.text;

    final updated = record == null
        ? await widget.healthRecordService.addRecord(
            type: selectedType,
            value: value,
          )
        : await widget.healthRecordService.updateRecord(
            id: record.id,
            type: selectedType,
            value: value,
          );

    valueController.dispose();

    if (!mounted) return;
    setState(() {
      _records = updated;
    });
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    final updated = await widget.healthRecordService.deleteRecord(record.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _records = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No active user')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.15
                : AppSpacing.lg;
            return CustomScrollView(
              slivers: [
                _AppBar(
                  hPad: hPad,
                  fullName: user.fullName,
                  email: user.email,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),
                      const SectionHeader(title: 'Dashboard'),
                      const SizedBox(height: AppSpacing.md),
                      const _IotMetricsGrid(),
                      const SizedBox(height: AppSpacing.xl),
                      SectionHeader(
                        title: 'Health Journal',
                        action: 'Log +',
                        onAction: _showRecordDialog,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_records.isEmpty)
                        const _EmptyRecordsState()
                      else
                        ..._records.map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _RecordCard(
                              record: record,
                              onEdit: () => _showRecordDialog(record: record),
                              onDelete: () => _deleteRecord(record),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecordDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.bg),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.hPad,
    required this.fullName,
    required this.email,
  });

  final double hPad;
  final String fullName;
  final String email;

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
                Text(email, style: AppText.muted),
                Text(fullName, style: AppText.h2),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: const Hero(
                tag: 'profile-avatar',
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.card,
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 22,
                  ),
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

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
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

class _EmptyRecordsState extends StatelessWidget {
  const _EmptyRecordsState();

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
