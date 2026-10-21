part of 'accounts_receivable_bloc.dart';

sealed class AccountsReceivableState extends BaseState {}

final class AccountsReceivableInitial extends AccountsReceivableState {}

final class AccountsReceivableInProgress extends AccountsReceivableState {}

final class AccountsReceivableSuccess extends AccountsReceivableState {
  final List<AccountReceivableItem> items;

  AccountsReceivableSuccess({required this.items});
}

final class AccountsReceivableError extends AccountsReceivableState {
  final String error;

  AccountsReceivableError({required this.error});
}
