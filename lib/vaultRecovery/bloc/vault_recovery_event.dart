import 'package:equatable/equatable.dart';

abstract class VaultRecoveryEvent extends Equatable {
  const VaultRecoveryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class VaultRecoveryUnlockSubmitted extends VaultRecoveryEvent {
  final String uid;
  final String email;
  final String recoveryPhrase;
  final String password;

  const VaultRecoveryUnlockSubmitted({
    required this.uid,
    required this.email,
    required this.recoveryPhrase,
    required this.password,
  });

  @override
  List<Object?> get props => <Object?>[uid, email, recoveryPhrase, password];
}

class VaultRecoveryResetSubmitted extends VaultRecoveryEvent {
  final String uid;
  final String email;
  final String password;

  const VaultRecoveryResetSubmitted({
    required this.uid,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => <Object?>[uid, email, password];
}
