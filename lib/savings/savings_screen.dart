import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/bloc/savings_bloc.dart';
import 'package:web_personal_finances/savings/repository/savings_repository.dart';
import 'package:web_personal_finances/savings/widget/savings_body.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<SavingsBloc>(
      create: (final BuildContext context) =>
          SavingsBloc(savingsRepository: SavingsRepository())
            ..add(SavingsFetched(userId: uid)),
      child: const Scaffold(backgroundColor: transparent, body: SavingsBody()),
    );
  }
}
