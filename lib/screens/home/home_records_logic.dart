part of '../home_screen.dart';

extension _HomeRecordsLogic on _HomeScreenState {
  Future<void> _openRecordDialog([HealthRecord? record]) async {
    final result = await showHealthRecordDialog(
      context,
      healthRecordService: widget.healthRecordService,
      record: record,
    );
    if (!mounted || result == null) return;
    if (record == null) {
      await widget.healthRecordService.addRecord(
        type: result.type,
        value: result.value,
      );
    } else {
      await widget.healthRecordService.updateRecord(
        id: record.id,
        type: result.type,
        value: result.value,
      );
    }
    if (!mounted) return;
    _refreshRecords();
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    await widget.healthRecordService.deleteRecord(record.id);
    if (!mounted) return;
    _refreshRecords();
  }

  void _refreshRecords() {
    _update(() {
      _recordsFuture = widget.healthRecordService.getRecords();
    });
  }
}
