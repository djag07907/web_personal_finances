part of 'savings_bloc.dart';

sealed class SavingsState extends BaseState {}

final class SavingsInitial extends SavingsState {}

final class SavingsInProgress extends SavingsState {}

final class SavingsSuccess extends SavingsState {
  final List<SavingItem> items;

  SavingsSuccess({required this.items});
}

final class SavingsError extends SavingsState {
  final String error;

  SavingsError({required this.error});
}
