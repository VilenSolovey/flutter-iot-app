import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/state/home/home_state.dart';

part 'home_connectivity_cubit.dart';

class HomeCubit extends Cubit<HomeState> with HomeConnectivityCubit {
  HomeCubit({
    required AuthService authService,
    required this.connectivityService,
    required HealthRecordService healthRecordService,
    required this.mqttService,
  })  : _authService = authService,
        _healthRecordService = healthRecordService,
        super(const HomeState());

  final AuthService _authService;
  final HealthRecordService _healthRecordService;

  @override
  final ConnectivityService connectivityService;

  @override
  final MqttService mqttService;

  Map<String, String> get allowedMetrics => HealthRecordService.allowedMetrics;

  String get temperatureTopic => mqttService.temperatureTopic;

  String? validateRecordValue(String value) {
    return _healthRecordService.validateValue(value);
  }

  Future<void> load() async {
    _bindMqttStreams();
    final user = await _authService.getActiveUser();
    if (isClosed) return;
    if (user == null) {
      emit(state.copyWith(shouldOpenLogin: true));
      return;
    }
    final records = await _healthRecordService.getRecords();
    if (isClosed) return;
    emit(
      state.copyWith(
        user: user,
        records: records,
        isLoading: false,
      ),
    );
    await _initializeConnectivity();
  }

  Future<void> saveRecord({
    required String type,
    required String value,
    HealthRecord? record,
  }) async {
    final records = record == null
        ? await _healthRecordService.addRecord(type: type, value: value)
        : await _healthRecordService.updateRecord(
            id: record.id,
            type: type,
            value: value,
          );
    if (!isClosed) emit(state.copyWith(records: records));
  }

  Future<void> deleteRecord(HealthRecord record) async {
    final records = await _healthRecordService.deleteRecord(record.id);
    if (!isClosed) emit(state.copyWith(records: records));
  }
}
