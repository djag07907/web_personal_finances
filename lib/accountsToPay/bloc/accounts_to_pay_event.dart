part of 'accounts_to_pay_bloc.dart';

sealed class AccountsToPayEvent extends Equatable {
  const AccountsToPayEvent();

  @override
  List<Object> get props => <Object>[];
}

final class AccountsToPayAdded extends AccountsToPayEvent {
  final AccountToPayItem item;

  const AccountsToPayAdded({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class AccountsToPayUpdated extends AccountsToPayEvent {
  final AccountToPayItem item;

  const AccountsToPayUpdated({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class AccountsToPayDeleted extends AccountsToPayEvent {
  final String id;
  final String userId;

  const AccountsToPayDeleted({required this.id, required this.userId});

  @override
  List<Object> get props => <Object>[id, userId];
}

final class AccountsToPayFetched extends AccountsToPayEvent {
  final String userId;

  const AccountsToPayFetched({required this.userId});

  @override
  List<Object> get props => <Object>[userId];
}
