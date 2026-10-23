import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_bloc.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_event.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_state.dart';

// Fake UserRepository for test
class _FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<UserModel?> getUser(final String id) async {
    return null; // Simulate user without vault
  }
}

// Fake AuthRepository whose password verification always succeeds
class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<void> verifyPassword({required final String password}) async {}
}

void main() {
  group('VaultRecoveryBloc Tests', () {
    test('initial state is VaultRecoveryInitial', () {
      final VaultRecoveryBloc bloc = VaultRecoveryBloc(
        userRepository: _FakeUserRepository(),
        authRepository: _FakeAuthRepository(),
      );
      expect(bloc.state, equals(VaultRecoveryInitial()));
    });

    test('emits InProgress then Failure when no vault exists for user', () async {
      final VaultRecoveryBloc bloc = VaultRecoveryBloc(
        userRepository: _FakeUserRepository(),
        authRepository: _FakeAuthRepository(),
      );

      expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          isA<VaultRecoveryInProgress>(),
          isA<VaultRecoveryFailure>().having(
            (final VaultRecoveryFailure s) => s.error,
            'error',
            contains('No encrypted vault found'),
          ),
        ]),
      );

      bloc.add(
        const VaultRecoveryUnlockSubmitted(
          uid: 'test-user-id',
          email: 'test@example.com',
          recoveryPhrase:
              'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
          password: 'password123',
        ),
      );
    });
  });
}
