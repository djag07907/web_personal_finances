import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/vaultSetup/bloc/vault_setup_bloc.dart';
import 'package:web_personal_finances/vaultSetup/widget/vault_setup_body.dart';

class VaultSetupScreen extends StatelessWidget {
  const VaultSetupScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<VaultSetupBloc>(
      create: (final BuildContext ctx) => VaultSetupBloc(
        userRepository: ctx.read<UserRepository>(),
        authRepository: ctx.read<AuthRepository>(),
      ),
      child: const VaultSetupBody(),
    );
  }
}
