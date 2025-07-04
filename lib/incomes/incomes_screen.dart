import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/incomes/bloc/incomes_bloc.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';
import 'package:web_personal_finances/incomes/widget/incomes_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<IncomesBloc>(
      create: (final BuildContext context) => IncomesBloc(
        incomeRepository: IncomeRepository(),
      ),
      child: Scaffold(
        backgroundColor: transparent,
        body: IncomesBody(),
      ),
    );
  }
}
