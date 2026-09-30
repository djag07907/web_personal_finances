import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/incomes/bloc/incomes_bloc.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';
import 'package:web_personal_finances/incomes/widget/incomes_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<IncomesBloc>(
      create: (final BuildContext context) =>
          IncomesBloc(incomeRepository: IncomeRepository())
            ..add(IncomesFetched(userId: uid)),
      child: const Scaffold(backgroundColor: transparent, body: IncomesBody()),
    );
  }
}
