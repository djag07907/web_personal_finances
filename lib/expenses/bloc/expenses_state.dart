part of 'expenses_bloc.dart';

sealed class ExpensesState extends BaseState {}

final class ExpensesInitial extends ExpensesState {}

final class ExpensesLoading extends ExpensesState {}

final class ExpensesInProgress extends ExpensesState {}

final class ExpensesSuccess extends ExpensesState {
  final List<ExpenseItem> expenses;

  ExpensesSuccess({required this.expenses});
}

final class ExpensesError extends ExpensesState {
  final String error;

  ExpensesError({required this.error});
}

final class ServerClientError extends ExpensesState {
  final String error;

  ServerClientError({required this.error});
}
