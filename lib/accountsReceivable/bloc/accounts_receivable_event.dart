part of 'accounts_receivable_bloc.dart';

sealed class AccountsReceivableEvent extends Equatable {
  const AccountsReceivableEvent();

  @override
  List<Object> get props => <Object>[];
}

final class AccountsReceivableAdded extends AccountsReceivableEvent {
  final AccountReceivableItem item;

  const AccountsReceivableAdded({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class AccountsReceivableUpdated extends AccountsReceivableEvent {
  final AccountReceivableItem item;

  const AccountsReceivableUpdated({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class AccountsReceivableDeleted extends AccountsReceivableEvent {
  final String id;
  final String userId;

  const AccountsReceivableDeleted({required this.id, required this.userId});

  @override
  List<Object> get props => <Object>[id, userId];
}

final class AccountsReceivableFetched extends AccountsReceivableEvent {
  final String userId;

  const AccountsReceivableFetched({required this.userId});

  @override
  List<Object> get props => <Object>[userId];
}
