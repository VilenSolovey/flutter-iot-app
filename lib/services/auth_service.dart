import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

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
  AuthService(this._repository);

  final AuthRepository _repository;

  String? validateFullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Введіть імʼя';
    }
    final hasOnlyLetters =
        RegExp(r'^[A-Za-zА-Яа-яІіЇїЄєҐґ\s\-]+$').hasMatch(trimmed);
    if (!hasOnlyLetters) {
      return 'Імʼя не має містити цифри чи спецсимволи';
    }
    if (trimmed.length < 2) {
      return 'Імʼя має містити мінімум 2 символи';
    }
    return null;
  }

  String? validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Введіть email';
    }
    final isValid = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(trimmed);
    if (!isValid) {
      return 'Некоректний email';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль має бути не менше 6 символів';
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Підтвердіть пароль';
    }
    if (password != confirmPassword) {
      return 'Паролі не співпадають';
    }
    return null;
  }

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
