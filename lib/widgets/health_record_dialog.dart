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
}) async {
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
                    items: types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          selectedType = value;
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
                        healthRecordService.validateValue(value ?? ''),
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
                  if (!isValid) {
                    return;
                  }

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
    return null;
  }

  final result = HealthRecordDialogResult(
    type: selectedType,
    value: valueController.text,
  );
  valueController.dispose();
  return result;
}
