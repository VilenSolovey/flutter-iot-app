import 'package:my_project/domain/models/user_profile.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = true,
    this.isSaving = false,
    this.message,
    this.shouldOpenLogin = false,
  });

  final UserProfile? user;
  final bool isLoading;
  final bool isSaving;
  final String? message;
  final bool shouldOpenLogin;

  ProfileState copyWith({
    UserProfile? user,
    bool? isLoading,
    bool? isSaving,
    String? message,
    bool? shouldOpenLogin,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      message: message,
      shouldOpenLogin: shouldOpenLogin ?? this.shouldOpenLogin,
    );
  }
}
