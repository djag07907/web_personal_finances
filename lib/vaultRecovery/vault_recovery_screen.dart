import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/vaultRecovery/bloc/vault_recovery_bloc.dart';
import 'package:web_personal_finances/vaultRecovery/widget/vault_recovery_body.dart';

class VaultRecoveryScreen extends StatelessWidget {
  const VaultRecoveryScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<VaultRecoveryBloc>(
      create: (final BuildContext ctx) =>
          VaultRecoveryBloc(userRepository: ctx.read<UserRepository>()),
      child: const VaultRecoveryBody(),
    );
  }
}
