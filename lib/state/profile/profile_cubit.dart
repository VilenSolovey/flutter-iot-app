import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/state/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthService authService,
    required HealthRecordService healthRecordService,
  })  : _authService = authService,
        _healthRecordService = healthRecordService,
        super(const ProfileState());

  final AuthService _authService;
  final HealthRecordService _healthRecordService;

  String? validateFullName(String value) =>
      _authService.validateFullName(value);

  String? validateEmail(String value) => _authService.validateEmail(value);

  Future<void> loadUser() async {
    final user = await _authService.getActiveUser();
    if (isClosed) return;
    if (user == null) {
      emit(state.copyWith(shouldOpenLogin: true));
      return;
    }
    emit(state.copyWith(user: user, isLoading: false));
  }

  Future<void> saveProfile({
    required UserProfile oldUser,
    required String fullName,
    required String email,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _authService.updateProfile(
      oldUser: oldUser,
      fullName: fullName,
      email: email,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        isSaving: false,
        user: result.user ?? state.user,
        message: result.message ?? 'Помилка оновлення профілю',
      ),
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    if (!isClosed) emit(state.copyWith(shouldOpenLogin: true));
  }

  Future<void> deleteAccount() async {
    await _authService.deleteUser();
    await _healthRecordService.clearAllRecords();
    if (!isClosed) emit(state.copyWith(shouldOpenLogin: true));
  }
}
