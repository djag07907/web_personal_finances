import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/expenses/bloc/expenses_bloc.dart';
import 'package:web_personal_finances/expenses/repository/expenses_repository.dart';
import 'package:web_personal_finances/expenses/widget/expenses_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<ExpensesBloc>(
      create: (final BuildContext context) =>
          ExpensesBloc(expenseRepository: ExpenseRepository())
            ..add(ExpensesFetched(userId: uid)),
      child: const Scaffold(backgroundColor: transparent, body: ExpensesBody()),
    );
  }
}
