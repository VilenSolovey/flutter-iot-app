class AuthValidators {
  const AuthValidators();

  String? fullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Введіть імʼя';
    }
    final isValid = RegExp(r'^[A-Za-zА-Яа-яІіЇїЄєҐґ\s\-]+$').hasMatch(trimmed);
    if (!isValid) {
      return 'Імʼя не має містити цифри чи спецсимволи';
    }
    if (trimmed.length < 2) {
      return 'Імʼя має містити мінімум 2 символи';
    }
    return null;
  }

  String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Введіть email';
    }
    final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
    return isValid ? null : 'Некоректний email';
  }

  String? password(String value) {
    if (value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль має бути не менше 6 символів';
    }
    return null;
  }

  String? confirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Підтвердіть пароль';
    }
    if (password != confirmPassword) {
      return 'Паролі не співпадають';
    }
    return null;
  }
}
