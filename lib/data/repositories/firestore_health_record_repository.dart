import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/repositories/health_record_repository.dart';

class FirestoreHealthRecordRepository implements HealthRecordRepository {
  FirestoreHealthRecordRepository({
    required FirebaseFirestore firestore,
    required HealthRecordRepository localRepository,
    this.collectionName = 'health_records',
  })  : _firestore = firestore,
        _localRepository = localRepository;

  final FirebaseFirestore _firestore;
  final HealthRecordRepository _localRepository;
  final String collectionName;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection(collectionName);
  }

  @override
  Future<void> clear() async {
    final cached = await _localRepository.getAll();
    await _localRepository.clear();
    await _syncRemote(<HealthRecord>[], existing: cached);
  }

  @override
  Future<List<HealthRecord>> getAll() async {
    final localRecords = await _localRepository.getAll();
    try {
      final snapshot =
          await _collection.orderBy('timestamp', descending: true).get();
      final remoteRecords = snapshot.docs.map(_recordFromDoc).toList();
      if (remoteRecords.isNotEmpty) {
        await _localRepository.saveAll(remoteRecords);
        return remoteRecords;
      }
      if (localRecords.isNotEmpty) {
        await _syncRemote(localRecords);
        return localRecords;
      }
      return <HealthRecord>[];
    } on FirebaseException {
      return localRecords;
    }
  }

  @override
  Future<void> saveAll(List<HealthRecord> records) async {
    final existing = await _localRepository.getAll();
    await _localRepository.saveAll(records);
    await _syncRemote(records, existing: existing);
  }

  HealthRecord _recordFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final timestamp = data['timestamp'];
    return HealthRecord(
      id: doc.id,
      type: data['type'] as String? ?? '',
      value: data['value'] as String? ?? '',
      unit: data['unit'] as String? ?? '',
      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.tryParse('$timestamp') ?? DateTime.now(),
    );
  }

  Future<void> _syncRemote(
    List<HealthRecord> records, {
    List<HealthRecord>? existing,
  }) async {
    try {
      final current = existing ?? await _localRepository.getAll();
      final batch = _firestore.batch();
      final nextIds = records.map((record) => record.id).toSet();

      for (final record in current) {
        if (!nextIds.contains(record.id)) {
          batch.delete(_collection.doc(record.id));
        }
      }

      for (final record in records) {
        batch.set(_collection.doc(record.id), <String, dynamic>{
          'type': record.type,
          'value': record.value,
          'unit': record.unit,
          'timestamp': Timestamp.fromDate(record.timestamp),
        });
      }

      await batch.commit();
    } on FirebaseException {
      return;
    }
  }
}
