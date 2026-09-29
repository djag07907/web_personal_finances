import 'package:firebase_auth/firebase_auth.dart';
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
    final SignUpSubmitted event,
    final Emitter<SignupState> emit,
  ) async {
    emit(SignUpInProgress());
    try {
      await authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(SignUpSuccess());
    } on FirebaseAuthException catch (e) {
      emit(SignUpError(error: _mapFirebaseError(e.code)));
    } on Exception catch (_) {
      emit(
        const SignUpError(
          error: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseError(final String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'weak-password':
        return 'Your password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is currently disabled. Contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Registration failed ($code). Please try again.';
    }
  }
}
