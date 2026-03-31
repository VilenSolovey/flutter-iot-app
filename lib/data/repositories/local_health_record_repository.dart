import 'dart:convert';

import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/repositories/health_record_repository.dart';

class LocalHealthRecordRepository implements HealthRecordRepository {
  LocalHealthRecordRepository(this._storage);

  final KeyValueStorage _storage;

  static const _recordsKey = 'health_records';

  @override
  Future<void> clear() async {
    await _storage.remove(_recordsKey);
  }

  @override
  Future<List<HealthRecord>> getAll() async {
    final raw = _storage.getString(_recordsKey);
    if (raw == null || raw.isEmpty) {
      return <HealthRecord>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => HealthRecord.fromMap(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> saveAll(List<HealthRecord> records) async {
    final serialized = jsonEncode(records.map((item) => item.toMap()).toList());
    await _storage.setString(_recordsKey, serialized);
  }
}
