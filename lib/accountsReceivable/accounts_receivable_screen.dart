import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/accountsReceivable/bloc/accounts_receivable_bloc.dart';
import 'package:web_personal_finances/accountsReceivable/repository/accounts_receivable_repository.dart';
import 'package:web_personal_finances/accountsReceivable/widget/accounts_receivable_body.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AccountsReceivableScreen extends StatelessWidget {
  const AccountsReceivableScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;

    return BlocProvider<AccountsReceivableBloc>(
      create: (final BuildContext context) => AccountsReceivableBloc(
        accountReceivableRepository: AccountReceivableRepository(),
      )..add(AccountsReceivableFetched(userId: uid)),
      child: const Scaffold(
        backgroundColor: transparent,
        body: AccountsReceivableBody(),
      ),
    );
  }
}
