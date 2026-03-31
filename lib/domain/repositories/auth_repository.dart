import 'package:my_project/domain/models/user_profile.dart';

abstract class AuthRepository {
  Future<void> register(UserProfile user);

  Future<UserProfile?> login({
    required String email,
    required String password,
  });

  Future<UserProfile?> getRegisteredUser();

  Future<UserProfile?> getLoggedInUser();

  Future<void> setLoggedInUser(UserProfile? user);

  Future<void> updateUser(UserProfile user);

  Future<void> deleteUser();
}
