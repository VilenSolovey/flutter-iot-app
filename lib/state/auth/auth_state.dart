class AuthState {
  const AuthState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
  });

  final bool isLoading;
  final String? message;
  final bool isSuccess;

  AuthState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
