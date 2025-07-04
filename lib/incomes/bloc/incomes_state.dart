part of 'incomes_bloc.dart';

sealed class IncomesState extends BaseState {}

final class IncomesInitial extends IncomesState {}

final class IncomesLoading extends IncomesState {}

final class IncomesInProgress extends IncomesState {}

final class IncomesSuccess extends IncomesState {
  final List<IncomeItem> incomes;

  IncomesSuccess({
    required this.incomes,
  });
}

final class IncomesError extends IncomesState {
  final String error;

  IncomesError({
    required this.error,
  });
}

final class ServerClientError extends IncomesState {
  final String error;

  ServerClientError({
    required this.error,
  });
}
