import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_bloc.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_event.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_state.dart';

class _FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<UserModel?> getUser(final String id) async => null;
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<void> verifyPassword({required final String password}) async {}
}

void main() {
  group('VaultSetupBloc Tests', () {
    test('initial state is VaultSetupInitial', () {
      final VaultSetupBloc bloc = VaultSetupBloc(
        userRepository: _FakeUserRepository(),
        authRepository: _FakeAuthRepository(),
      );
      expect(bloc.state, equals(VaultSetupInitial()));
    });

    test('emits InProgress then Failure when profile is missing', () async {
      final VaultSetupBloc bloc = VaultSetupBloc(
        userRepository: _FakeUserRepository(),
        authRepository: _FakeAuthRepository(),
      );

      expectLater(
        bloc.stream,
        emitsInOrder(<dynamic>[
          isA<VaultSetupInProgress>(),
          isA<VaultSetupFailure>().having(
            (final VaultSetupFailure s) => s.error,
            'error',
            contains('Profile not found'),
          ),
        ]),
      );

      bloc.add(
        const VaultSetupSubmitted(
          uid: 'uid',
          recoveryPhrase: 'a b c d e f g h i j k l',
          password: 'password123',
        ),
      );
    });
  });
}
