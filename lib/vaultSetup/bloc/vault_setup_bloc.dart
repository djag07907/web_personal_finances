import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_event.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_state.dart';

class VaultSetupBloc extends Bloc<VaultSetupEvent, VaultSetupState> {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final EncryptionService encryptionService;

  VaultSetupBloc({
    required this.userRepository,
    required this.authRepository,
    final EncryptionService? encryptionService,
  }) : encryptionService = encryptionService ?? EncryptionService(),
       super(VaultSetupInitial()) {
    on<VaultSetupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    final VaultSetupSubmitted event,
    final Emitter<VaultSetupState> emit,
  ) async {
    emit(VaultSetupInProgress());
    try {
      await authRepository.verifyPassword(password: event.password);

      final UserModel? profile = await userRepository.getUser(event.uid);
      if (profile == null) {
        throw Exception('Profile not found. Please sign in again.');
      }

      final SecretKey dek = await encryptionService.generateDataEncryptionKey();
      final List<int> salt = encryptionService.generateSalt();
      final Map<String, dynamic> vault = await encryptionService.createVault(
        dek: dek,
        password: event.password,
        recoveryPhrase: event.recoveryPhrase,
        salt: salt,
      );

      await userRepository.saveUser(profile.copyWith(vault: vault));

      SessionVault.instance.setDek(dek);
      SessionVault.instance.setRecoveryPhrase(event.recoveryPhrase);
      SessionVault.instance.clearPendingAuthPassword();

      emit(VaultSetupSuccess());
    } on FirebaseAuthException catch (e) {
      emit(VaultSetupFailure(error: _mapAuthError(e.code)));
    } catch (e) {
      emit(
        VaultSetupFailure(error: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  String _mapAuthError(final String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Enter the password you currently use to sign in.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      default:
        return 'Could not verify your password ($code). Please sign in again.';
    }
  }
}
