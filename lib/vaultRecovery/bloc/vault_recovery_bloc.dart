import 'package:cryptography/cryptography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/security/bip39_words.dart';
import 'package:web_personal_finances/commons/security/encryption_service.dart';
import 'package:web_personal_finances/commons/security/session_vault.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_event.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_state.dart';

class VaultRecoveryBloc extends Bloc<VaultRecoveryEvent, VaultRecoveryState> {
  final UserRepository userRepository;
  final EncryptionService encryptionService;

  VaultRecoveryBloc({
    required this.userRepository,
    final EncryptionService? encryptionService,
  }) : encryptionService = encryptionService ?? EncryptionService(),
       super(VaultRecoveryInitial()) {
    on<VaultRecoveryUnlockSubmitted>(_onUnlockSubmitted);
    on<VaultRecoveryResetSubmitted>(_onResetSubmitted);
  }

  Future<void> _onUnlockSubmitted(
    final VaultRecoveryUnlockSubmitted event,
    final Emitter<VaultRecoveryState> emit,
  ) async {
    emit(VaultRecoveryInProgress());
    try {
      final UserModel? profile = await userRepository.getUser(event.uid);
      if (profile == null || profile.vault == null) {
        throw Exception('No encrypted vault found for this account.');
      }

      final SecretKey? dek = await encryptionService
          .unlockVaultWithRecoveryPhrase(profile.vault!, event.recoveryPhrase);

      if (dek == null) {
        throw Exception(
          'Invalid recovery key. The key does not match this account vault.',
        );
      }

      final List<int> salt = encryptionService.generateSalt();
      final Map<String, dynamic> newVault = await encryptionService.createVault(
        dek: dek,
        password: event.password,
        recoveryPhrase: event.recoveryPhrase,
        salt: salt,
      );

      await userRepository.saveUser(profile.copyWith(vault: newVault));

      SessionVault.instance.setDek(dek);
      SessionVault.instance.setRecoveryPhrase(event.recoveryPhrase);

      emit(VaultRecoverySuccess(recoveryPhrase: event.recoveryPhrase));
    } catch (e) {
      emit(
        VaultRecoveryFailure(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onResetSubmitted(
    final VaultRecoveryResetSubmitted event,
    final Emitter<VaultRecoveryState> emit,
  ) async {
    emit(VaultRecoveryResetInProgress());
    try {
      final SecretKey newDek = await encryptionService
          .generateDataEncryptionKey();
      final String newPhrase = generateRecoveryPhrase();
      final List<int> salt = encryptionService.generateSalt();

      final Map<String, dynamic> freshVault = await encryptionService
          .createVault(
            dek: newDek,
            password: event.password,
            recoveryPhrase: newPhrase,
            salt: salt,
          );

      final UserModel? profile = await userRepository.getUser(event.uid);
      if (profile != null) {
        await userRepository.saveUser(profile.copyWith(vault: freshVault));
      }

      SessionVault.instance.setDek(newDek);
      SessionVault.instance.setRecoveryPhrase(newPhrase);

      emit(VaultRecoveryResetSuccess(recoveryPhrase: newPhrase));
    } catch (e) {
      emit(
        VaultRecoveryFailure(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
