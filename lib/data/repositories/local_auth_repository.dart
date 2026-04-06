import 'dart:convert';

import 'package:my_project/data/storage/key_value_storage.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage);

  final KeyValueStorage _storage;

  static const _registeredUserKey = 'registered_user';
  static const _loggedInEmailKey = 'logged_in_email';

  @override
  Future<UserProfile?> getLoggedInUser() async {
    final email = _storage.getString(_loggedInEmailKey);
    if (email == null || email.isEmpty) {
      return null;
    }
    final user = await getRegisteredUser();
    if (user == null || user.email.toLowerCase() != email.toLowerCase()) {
      return null;
    }
    return user;
  }

  @override
  Future<UserProfile?> getRegisteredUser() async {
    final raw = _storage.getString(_registeredUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromMap(decoded);
  }

  @override
  Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    final user = await getRegisteredUser();
    if (user == null) {
      return null;
    }

    final normalizedEmail = email.trim().toLowerCase();
    final isMatch = user.email.toLowerCase() == normalizedEmail &&
        user.password == password;

    if (!isMatch) {
      return null;
    }

    await _storage.setString(_loggedInEmailKey, user.email);
    return user;
  }

  @override
  Future<void> register(UserProfile user) async {
    final serialized = jsonEncode(user.toMap());
    await _storage.setString(_registeredUserKey, serialized);
    await _storage.setString(_loggedInEmailKey, user.email);
  }

  @override
  Future<void> setLoggedInUser(UserProfile? user) async {
    if (user == null) {
      await _storage.remove(_loggedInEmailKey);
      return;
    }
    await _storage.setString(_loggedInEmailKey, user.email);
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    final serialized = jsonEncode(user.toMap());
    await _storage.setString(_registeredUserKey, serialized);

    final current = _storage.getString(_loggedInEmailKey);
    if (current != null && current.isNotEmpty) {
      await _storage.setString(_loggedInEmailKey, user.email);
    }
  }

  @override
  Future<void> deleteUser() async {
    await _storage.remove(_registeredUserKey);
    await _storage.remove(_loggedInEmailKey);
  }
}
