import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';
import 'package:my_project/services/auth_validators.dart';

class AuthResult {
  const AuthResult({
    required this.isSuccess,
    this.message,
    this.user,
  });

  final bool isSuccess;
  final String? message;
  final UserProfile? user;
}

class AuthService {
  AuthService(this._repository, {AuthValidators? validators})
      : _validators = validators ?? const AuthValidators();

  final AuthRepository _repository;
  final AuthValidators _validators;

  String? validateFullName(String value) => _validators.fullName(value);

  String? validateEmail(String value) => _validators.email(value);

  String? validatePassword(String value) => _validators.password(value);

  String? validateConfirmPassword(String password, String confirmPassword) =>
      _validators.confirmPassword(password, confirmPassword);

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final fullNameError = validateFullName(fullName);
    if (fullNameError != null) {
      return AuthResult(isSuccess: false, message: fullNameError);
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      return AuthResult(isSuccess: false, message: emailError);
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return AuthResult(isSuccess: false, message: passwordError);
    }

    final confirmError = validateConfirmPassword(password, confirmPassword);
    if (confirmError != null) {
      return AuthResult(isSuccess: false, message: confirmError);
    }

    final user = UserProfile(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
    );
    await _repository.register(user);
    return AuthResult(
      isSuccess: true,
      user: user,
      message: 'Реєстрація успішна',
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      return AuthResult(isSuccess: false, message: emailError);
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      return AuthResult(isSuccess: false, message: passwordError);
    }

    final user = await _repository.login(
      email: email,
      password: password,
    );

    if (user == null) {
      return const AuthResult(
        isSuccess: false,
        message: 'Невірний email або пароль',
      );
    }

    return AuthResult(
      isSuccess: true,
      user: user,
      message: 'Вхід успішний',
    );
  }

  Future<UserProfile?> getActiveUser() {
    return _repository.getLoggedInUser();
  }

  Future<bool> hasActiveSession() async {
    final user = await _repository.getLoggedInUser();
    return user != null;
  }

  Future<void> logout() {
    return _repository.setLoggedInUser(null);
  }

  Future<AuthResult> updateProfile({
    required UserProfile oldUser,
    required String fullName,
    required String email,
  }) async {
    final fullNameError = validateFullName(fullName);
    if (fullNameError != null) {
      return AuthResult(isSuccess: false, message: fullNameError);
    }

    final emailError = validateEmail(email);
    if (emailError != null) {
      return AuthResult(isSuccess: false, message: emailError);
    }

    final updated = oldUser.copyWith(
      fullName: fullName.trim(),
      email: email.trim(),
    );
    await _repository.updateUser(updated);
    await _repository.setLoggedInUser(updated);

    return AuthResult(
      isSuccess: true,
      user: updated,
      message: 'Профіль оновлено',
    );
  }

  Future<void> deleteUser() {
    return _repository.deleteUser();
  }
}
