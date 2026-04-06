import 'package:my_project/data/repositories/local_auth_repository.dart';
import 'package:my_project/data/repositories/local_health_record_repository.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  AppDependencies({
    required this.authService,
    required this.healthRecordService,
  });

  final AuthService authService;
  final HealthRecordService healthRecordService;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SharedPrefsStorage(prefs);
    final authRepository = LocalAuthRepository(storage);
    final recordRepository = LocalHealthRecordRepository(storage);

    return AppDependencies(
      authService: AuthService(authRepository),
      healthRecordService: HealthRecordService(recordRepository),
    );
  }
}
