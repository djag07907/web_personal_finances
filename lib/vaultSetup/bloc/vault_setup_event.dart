import 'package:equatable/equatable.dart';

abstract class VaultSetupEvent extends Equatable {
  const VaultSetupEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class VaultSetupSubmitted extends VaultSetupEvent {
  final String uid;
  final String recoveryPhrase;
  final String password;

  const VaultSetupSubmitted({
    required this.uid,
    required this.recoveryPhrase,
    required this.password,
  });

  @override
  List<Object?> get props => <Object?>[uid, recoveryPhrase, password];
}
