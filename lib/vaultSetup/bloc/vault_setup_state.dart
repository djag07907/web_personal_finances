import 'package:equatable/equatable.dart';

abstract class VaultSetupState extends Equatable {
  const VaultSetupState();

  @override
  List<Object?> get props => <Object?>[];
}

class VaultSetupInitial extends VaultSetupState {}

class VaultSetupInProgress extends VaultSetupState {}

class VaultSetupSuccess extends VaultSetupState {}

class VaultSetupFailure extends VaultSetupState {
  final String error;

  const VaultSetupFailure({required this.error});

  @override
  List<Object?> get props => <Object?>[error];
}
