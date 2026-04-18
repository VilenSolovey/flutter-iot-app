import 'package:flutter/material.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/theme/app_theme.dart';

class HealthRecordDialogResult {
  const HealthRecordDialogResult({
    required this.type,
    required this.value,
  });

  final String type;
  final String value;
}

Future<HealthRecordDialogResult?> showHealthRecordDialog(
  BuildContext context, {
  required HealthRecordService healthRecordService,
  HealthRecord? record,
}) {
  return showDialog<HealthRecordDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _HealthRecordDialog(
      healthRecordService: healthRecordService,
      record: record,
    ),
  );
}

class _HealthRecordDialog extends StatefulWidget {
  const _HealthRecordDialog({
    required this.healthRecordService,
    this.record,
  });

  final HealthRecordService healthRecordService;
  final HealthRecord? record;

  @override
  State<_HealthRecordDialog> createState() => _HealthRecordDialogState();
}

class _HealthRecordDialogState extends State<_HealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final List<String> _types;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _types = HealthRecordService.allowedMetrics.keys.toList();
    _selectedType = widget.record?.type ?? _types.first;
    _valueController = TextEditingController(text: widget.record?.value ?? '');
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    Navigator.pop(
      context,
      HealthRecordDialogResult(
        type: _selectedType,
        value: _valueController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        isEditing ? 'Edit Vital Sign' : 'Add Vital Sign',
        style: AppText.h2,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metric Type', style: AppText.label),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              dropdownColor: AppColors.card,
              style: AppText.body,
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedType = value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _valueController,
              style: AppText.body,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Value',
                hintText: 'e.g. 75',
                suffixText: HealthRecordService.allowedMetrics[_selectedType],
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
