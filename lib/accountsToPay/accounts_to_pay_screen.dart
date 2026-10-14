import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/accountsToPay/bloc/accounts_to_pay_bloc.dart';
import 'package:web_personal_finances/accountsToPay/repository/accounts_to_pay_repository.dart';
import 'package:web_personal_finances/accountsToPay/widget/accounts_to_pay_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AccountsToPayScreen extends StatelessWidget {
  const AccountsToPayScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<AccountsToPayBloc>(
      create: (final BuildContext context) =>
          AccountsToPayBloc(accountToPayRepository: AccountToPayRepository())
            ..add(AccountsToPayFetched(userId: uid)),
      child: const Scaffold(
        backgroundColor: transparent,
        body: AccountsToPayBody(),
      ),
    );
  }
}
