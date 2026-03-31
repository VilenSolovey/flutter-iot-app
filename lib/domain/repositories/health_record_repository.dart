import 'package:my_project/domain/models/health_record.dart';

abstract class HealthRecordRepository {
  Future<List<HealthRecord>> getAll();

  Future<void> saveAll(List<HealthRecord> records);

  Future<void> clear();
}
