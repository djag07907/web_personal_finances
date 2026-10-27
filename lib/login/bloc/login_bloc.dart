import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/recovery_key_utils.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  LoginBloc({
    required this.authRepository,
    final UserRepository? userRepository,
  }) : userRepository = userRepository ?? UserRepository(),
       super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    final LoginSubmitted event,
    final Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    SessionVault.instance.beginUnlock();
    try {
      final UserCredential credential = await authRepository
          .signInWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );

      final String uid =
          credential.user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        final UserModel? profile = await userRepository.getUser(uid);
        if (profile?.vault != null) {
          final SecretKey? dek = await EncryptionService()
              .unlockVaultWithPassword(profile!.vault!, event.password);
          if (dek != null) {
            SessionVault.instance.setDek(dek);
          } else {
            SessionVault.instance.setPendingAuthPassword(event.password);
            final String? preloadedPhrase =
                SessionVault.instance.recoveryPhrase;
            if (preloadedPhrase != null) {
              final EncryptionService encryptionService = EncryptionService();
              final SecretKey? recoveredDek = await encryptionService
                  .unlockVaultWithRecoveryPhrase(
                    profile.vault!,
                    preloadedPhrase,
                  );
              if (recoveredDek != null) {
                final List<int> salt = encryptionService.generateSalt();
                final Map<String, dynamic> updatedVault =
                    await encryptionService.createVault(
                      dek: recoveredDek,
                      password: event.password,
                      recoveryPhrase: preloadedPhrase,
                      salt: salt,
                    );
                await userRepository.saveUser(
                  profile.copyWith(vault: updatedVault),
                );
                SessionVault.instance.setDek(recoveredDek);
                RecoveryKeyUtils.downloadEmergencyKey(
                  email: profile.email,
                  uid: uid,
                  recoveryPhrase: preloadedPhrase,
                );
              }
            }
          }
        } else if (profile != null) {
          // Existing account without a vault: the vault setup screen will
          // create one using this (already verified) login password.
          SessionVault.instance.setPendingAuthPassword(event.password);
        }
      }

      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginError(error: _mapFirebaseError(e.code)));
    } on Exception catch (_) {
      emit(
        const LoginError(
          error: 'An unexpected error occurred. Please try again.',
        ),
      );
    } finally {
      SessionVault.instance.endUnlock();
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseError(final String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Sign-in failed ($code). Please try again.';
    }
  }
}
