import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/repositories/health_record_repository.dart';

class HealthRecordService {
  HealthRecordService(this._repository);

  final HealthRecordRepository _repository;

  static const Map<String, String> allowedMetrics = {
    'Water Intake': 'ml',
    'Weight': 'kg',
    'Blood Pressure': 'mmHg',
    'Blood Sugar': 'mg/dL',
    'Sleep': 'hrs',
    'Calories': 'kcal',
  };

  Future<List<HealthRecord>> getRecords() {
    return _repository.getAll();
  }

  Future<List<HealthRecord>> addRecord({
    required String type,
    required String value,
  }) async {
    final current = await _repository.getAll();
    final unit = allowedMetrics[type] ?? '';
    final record = HealthRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      value: value.trim(),
      unit: unit,
      timestamp: DateTime.now(),
    );
    final updated = [...current, record];
    await _repository.saveAll(updated);
    return _sortRecords(updated);
  }

  Future<List<HealthRecord>> updateRecord({
    required String id,
    required String type,
    required String value,
  }) async {
    final current = await _repository.getAll();
    final unit = allowedMetrics[type] ?? '';
    final updated = current
        .map(
          (record) => record.id == id
              ? record.copyWith(
                  type: type,
                  value: value.trim(),
                  unit: unit,
                )
              : record,
        )
        .toList();
    await _repository.saveAll(updated);
    return _sortRecords(updated);
  }

  Future<List<HealthRecord>> deleteRecord(String id) async {
    final current = await _repository.getAll();
    final updated = current.where((record) => record.id != id).toList();
    await _repository.saveAll(updated);
    return updated;
  }

  Future<void> clearAllRecords() {
    return _repository.clear();
  }

  String? validateValue(String value) {
    if (value.trim().isEmpty) {
      return 'Введіть значення';
    }
    return null;
  }

  List<HealthRecord> _sortRecords(List<HealthRecord> records) {
    return List.from(records)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
