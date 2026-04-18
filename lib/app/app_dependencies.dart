import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/data/repositories/firestore_health_record_repository.dart';
import 'package:my_project/data/repositories/local_auth_repository.dart';
import 'package:my_project/data/repositories/local_health_record_repository.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  AppDependencies({
    required this.authService,
    required this.connectivityService,
    required this.healthRecordService,
    required this.mqttService,
  });

  final AuthService authService;
  final ConnectivityService connectivityService;
  final HealthRecordService healthRecordService;
  final MqttService mqttService;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SharedPrefsStorage(prefs);
    final authRepository = LocalAuthRepository(storage);
    final localRecordRepository = LocalHealthRecordRepository(storage);
    final recordRepository = FirestoreHealthRecordRepository(
      firestore: FirebaseFirestore.instance,
      localRepository: localRecordRepository,
    );

    return AppDependencies(
      authService: AuthService(authRepository),
      connectivityService: ConnectivityService(),
      healthRecordService: HealthRecordService(recordRepository),
      mqttService: MqttService(),
    );
  }
}
