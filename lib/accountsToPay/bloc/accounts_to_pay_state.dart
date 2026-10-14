part of 'accounts_to_pay_bloc.dart';

sealed class AccountsToPayState extends BaseState {}

final class AccountsToPayInitial extends AccountsToPayState {}

final class AccountsToPayInProgress extends AccountsToPayState {}

final class AccountsToPaySuccess extends AccountsToPayState {
  final List<AccountToPayItem> items;

  AccountsToPaySuccess({required this.items});
}

final class AccountsToPayError extends AccountsToPayState {
  final String error;

  AccountsToPayError({required this.error});
}
