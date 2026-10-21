import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeFetchProfile extends HomeEvent {
  const HomeFetchProfile({required this.uid});

  final String uid;

  @override
  List<Object?> get props => <Object?>[uid];
}

class HomeIncomesUpdated extends HomeEvent {
  const HomeIncomesUpdated({required this.incomes});

  final List<IncomeItem> incomes;

  @override
  List<Object?> get props => <Object?>[incomes];
}

class HomeExpensesUpdated extends HomeEvent {
  const HomeExpensesUpdated({required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  List<Object?> get props => <Object?>[expenses];
}

class HomeAccountsToPayUpdated extends HomeEvent {
  const HomeAccountsToPayUpdated({required this.accountsToPay});

  final List<AccountToPayItem> accountsToPay;

  @override
  List<Object?> get props => <Object?>[accountsToPay];
}

class HomeAccountsReceivableUpdated extends HomeEvent {
  const HomeAccountsReceivableUpdated({required this.accountsReceivable});

  final List<AccountReceivableItem> accountsReceivable;

  @override
  List<Object?> get props => <Object?>[accountsReceivable];
}
