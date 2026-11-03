import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel profile;
  final List<IncomeItem> incomes;
  final List<ExpenseItem> expenses;
  final List<AccountToPayItem> accountsToPay;
  final List<AccountReceivableItem> accountsReceivable;
  final List<SavingItem> savings;

  const HomeLoaded({
    required this.profile,
    this.incomes = const <IncomeItem>[],
    this.expenses = const <ExpenseItem>[],
    this.accountsToPay = const <AccountToPayItem>[],
    this.accountsReceivable = const <AccountReceivableItem>[],
    this.savings = const <SavingItem>[],
  });

  HomeLoaded copyWith({
    final UserModel? profile,
    final List<IncomeItem>? incomes,
    final List<ExpenseItem>? expenses,
    final List<AccountToPayItem>? accountsToPay,
    final List<AccountReceivableItem>? accountsReceivable,
    final List<SavingItem>? savings,
  }) {
    return HomeLoaded(
      profile: profile ?? this.profile,
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
      accountsToPay: accountsToPay ?? this.accountsToPay,
      accountsReceivable: accountsReceivable ?? this.accountsReceivable,
      savings: savings ?? this.savings,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    profile,
    incomes,
    expenses,
    accountsToPay,
    accountsReceivable,
    savings,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}
