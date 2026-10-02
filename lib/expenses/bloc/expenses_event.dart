part of 'expenses_bloc.dart';

sealed class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object> get props => <Object>[];
}

final class ExpensesAdded extends ExpensesEvent {
  final ExpenseItem expenseItem;

  const ExpensesAdded({required this.expenseItem});

  @override
  List<Object> get props => <Object>[expenseItem];
}

final class ExpensesUpdated extends ExpensesEvent {
  final ExpenseItem expenseItem;

  const ExpensesUpdated({required this.expenseItem});

  @override
  List<Object> get props => <Object>[expenseItem];
}

final class ExpensesDeleted extends ExpensesEvent {
  final String id;
  final String userId;

  const ExpensesDeleted({required this.id, required this.userId});

  @override
  List<Object> get props => <Object>[id, userId];
}

final class ExpensesFetched extends ExpensesEvent {
  final String userId;

  const ExpensesFetched({required this.userId});

  @override
  List<Object> get props => <Object>[userId];
}
