import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    final LoginSubmitted event,
    final Emitter<LoginState> emit,
  ) async {
    emit(
      LoginInProgress(),
    );
    try {
      await authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(
        LoginSuccess(),
      );
    } on Exception catch (error) {
      emit(
        LoginError(
          error: error.toString(),
        ),
      );
    }
  }
}
