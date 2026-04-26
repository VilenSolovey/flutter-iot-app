import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthService authService,
    ConnectivityService? connectivityService,
  })  : _authService = authService,
        _connectivityService = connectivityService,
        super(const AuthState());

  final AuthService _authService;
  final ConnectivityService? _connectivityService;

  String? validateFullName(String value) =>
      _authService.validateFullName(value);

  String? validateEmail(String value) => _authService.validateEmail(value);

  String? validatePassword(String value) =>
      _authService.validatePassword(value);

  String? validateConfirmPassword(String password, String confirmPassword) {
    return _authService.validateConfirmPassword(password, confirmPassword);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final connectivityService = _connectivityService;
    if (connectivityService != null) {
      final hasInternet = await connectivityService.hasInternetConnection();
      if (!hasInternet) {
        emit(
          const AuthState(
            message:
                'Немає інтернету. Увійти можна лише після відновлення мережі.',
          ),
        );
        return;
      }
    }

    emit(const AuthState(isLoading: true));
    final result = await _authService.login(email: email, password: password);
    emit(
      AuthState(
        isSuccess: result.isSuccess,
        message: result.isSuccess ? null : result.message,
      ),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(const AuthState(isLoading: true));
    final result = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    emit(
      AuthState(
        isSuccess: result.isSuccess,
        message: result.isSuccess ? null : result.message,
      ),
    );
  }
}
