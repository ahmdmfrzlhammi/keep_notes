import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keep_notes/blocs/auth/auth_event.dart';
import 'package:keep_notes/blocs/auth/auth_repository.dart';
import 'package:keep_notes/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final userId = await authRepository.login(event.email, event.password);
        emit(AuthAuthenticatedState(userId: userId));
      } catch (e) {
        emit(AuthErrorState(errorMessage: e.toString()));
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final userId = await authRepository.register(
          event.email, 
          event.password,
          event.username
        );
        emit(AuthAuthenticatedState(userId: userId));
      } catch (e) {
        emit(AuthErrorState(errorMessage: e.toString()));
      }
    });

    on<AuthResetPasswordEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.resetPassword(event.email);
        emit(AuthPasswordResetSentState());
      } catch (e) {
        emit(AuthErrorState(errorMessage: e.toString()));
      }
    });

    on<AuthLogoutEvent>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticatedState());
    });
  }
}