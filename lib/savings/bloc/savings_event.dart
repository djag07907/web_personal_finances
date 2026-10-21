part of 'savings_bloc.dart';

sealed class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object> get props => <Object>[];
}

final class SavingsFetched extends SavingsEvent {
  final String userId;

  const SavingsFetched({required this.userId});

  @override
  List<Object> get props => <Object>[userId];
}

final class SavingAdded extends SavingsEvent {
  final SavingItem item;

  const SavingAdded({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class SavingUpdated extends SavingsEvent {
  final SavingItem item;

  const SavingUpdated({required this.item});

  @override
  List<Object> get props => <Object>[item];
}

final class SavingDeleted extends SavingsEvent {
  final String id;
  final String userId;

  const SavingDeleted({required this.id, required this.userId});

  @override
  List<Object> get props => <Object>[id, userId];
}

final class SavingTransactionRecorded extends SavingsEvent {
  final String savingId;
  final SavingRegistryItem transaction;
  final String userId;

  const SavingTransactionRecorded({
    required this.savingId,
    required this.transaction,
    required this.userId,
  });

  @override
  List<Object> get props => <Object>[savingId, transaction, userId];
}
