abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final String userId;

  AuthAuthenticatedState({required this.userId});
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String errorMessage;

  AuthErrorState({required this.errorMessage});
}

class AuthPasswordResetSentState extends AuthState {}