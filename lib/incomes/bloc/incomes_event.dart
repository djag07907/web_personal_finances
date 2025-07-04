part of 'incomes_bloc.dart';

sealed class IncomesEvent extends Equatable {
  const IncomesEvent();

  @override
  List<Object> get props => <Object>[];
}

final class IncomesAdded extends IncomesEvent {
  final IncomeItem incomeItem;

  IncomesAdded({
    required this.incomeItem,
  });
}

final class IncomesUpdated extends IncomesEvent {
  final IncomeItem incomeItem;

  IncomesUpdated({
    required this.incomeItem,
  });
}

final class IncomesDeleted extends IncomesEvent {
  final String id;

  IncomesDeleted({
    required this.id,
  });
}

final class IncomesFetched extends IncomesEvent {}
