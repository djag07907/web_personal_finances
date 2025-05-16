import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/signUp/bloc/signup_event.dart';
import 'package:web_personal_finances/signUp/bloc/signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;
  SignupBloc({required this.authRepository}) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }
  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(
      SignUpInProgress(),
    );
    try {
      await authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(
        SignUpSuccess(),
      );
    } on Exception catch (error) {
      emit(
        SignUpError(
          error: error.toString(),
        ),
      );
    }
  }
}
