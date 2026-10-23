import 'package:equatable/equatable.dart';

abstract class VaultRecoveryState extends Equatable {
  const VaultRecoveryState();

  @override
  List<Object?> get props => <Object?>[];
}

class VaultRecoveryInitial extends VaultRecoveryState {}

class VaultRecoveryInProgress extends VaultRecoveryState {}

class VaultRecoveryResetInProgress extends VaultRecoveryState {}

class VaultRecoverySuccess extends VaultRecoveryState {
  final String recoveryPhrase;

  const VaultRecoverySuccess({required this.recoveryPhrase});

  @override
  List<Object?> get props => <Object?>[recoveryPhrase];
}

class VaultRecoveryResetSuccess extends VaultRecoveryState {
  final String recoveryPhrase;

  const VaultRecoveryResetSuccess({required this.recoveryPhrase});

  @override
  List<Object?> get props => <Object?>[recoveryPhrase];
}

class VaultRecoveryFailure extends VaultRecoveryState {
  final String error;

  const VaultRecoveryFailure({required this.error});

  @override
  List<Object?> get props => <Object?>[error];
}
