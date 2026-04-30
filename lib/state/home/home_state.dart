import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/models/user_profile.dart';

class HomeState {
  const HomeState({
    this.user,
    this.records = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.isMqttConnected = false,
    this.isConnectingToMqtt = false,
    this.heartRate = '--',
    this.temperature = '--',
    this.message,
    this.shouldOpenLogin = false,
  });

  final UserProfile? user;
  final List<HealthRecord> records;
  final bool isLoading;
  final bool isOnline;
  final bool isMqttConnected;
  final bool isConnectingToMqtt;
  final String heartRate;
  final String temperature;
  final String? message;
  final bool shouldOpenLogin;

  HomeState copyWith({
    UserProfile? user,
    List<HealthRecord>? records,
    bool? isLoading,
    bool? isOnline,
    bool? isMqttConnected,
    bool? isConnectingToMqtt,
    String? heartRate,
    String? temperature,
    String? message,
    bool? shouldOpenLogin,
  }) {
    return HomeState(
      user: user ?? this.user,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      isMqttConnected: isMqttConnected ?? this.isMqttConnected,
      isConnectingToMqtt: isConnectingToMqtt ?? this.isConnectingToMqtt,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      message: message,
      shouldOpenLogin: shouldOpenLogin ?? this.shouldOpenLogin,
    );
  }
}
