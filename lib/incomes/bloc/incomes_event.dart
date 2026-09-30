part of 'incomes_bloc.dart';

sealed class IncomesEvent extends Equatable {
  const IncomesEvent();

  @override
  List<Object> get props => <Object>[];
}

final class IncomesAdded extends IncomesEvent {
  final IncomeItem incomeItem;

  const IncomesAdded({required this.incomeItem});

  @override
  List<Object> get props => <Object>[incomeItem];
}

final class IncomesUpdated extends IncomesEvent {
  final IncomeItem incomeItem;

  const IncomesUpdated({required this.incomeItem});

  @override
  List<Object> get props => <Object>[incomeItem];
}

final class IncomesDeleted extends IncomesEvent {
  final String id;
  final String userId;

  const IncomesDeleted({required this.id, required this.userId});

  @override
  List<Object> get props => <Object>[id, userId];
}

final class IncomesFetched extends IncomesEvent {
  final String userId;

  const IncomesFetched({required this.userId});

  @override
  List<Object> get props => <Object>[userId];
}
