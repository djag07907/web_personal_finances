import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/expenses/repository/expenses_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, BaseState> {
  final ExpenseRepository expenseRepository;

  ExpensesBloc({required this.expenseRepository}) : super(ExpensesInitial()) {
    on<ExpensesAdded>(_onExpenseAdded);
    on<ExpensesUpdated>(_onExpenseUpdated);
    on<ExpensesDeleted>(_onExpenseDeleted);
    on<ExpensesFetched>(_onExpenseFetched);
  }

  Future<void> _onExpenseAdded(
    final ExpensesAdded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(ExpensesInProgress());
    try {
      await expenseRepository.addExpense(event.expenseItem);
      final String userId = event.expenseItem.userId.isNotEmpty
          ? event.expenseItem.userId
          : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
      final List<ExpenseItem> expenses = await expenseRepository
          .getExpenses(userId)
          .first;
      emit(ExpensesSuccess(expenses: expenses));
    } catch (error) {
      emit(ExpensesError(error: error.toString()));
    }
  }

  Future<void> _onExpenseUpdated(
    final ExpensesUpdated event,
    final Emitter<BaseState> emit,
  ) async {
    emit(ExpensesInProgress());
    try {
      await expenseRepository.updateExpense(event.expenseItem);
      final String userId = event.expenseItem.userId.isNotEmpty
          ? event.expenseItem.userId
          : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
      final List<ExpenseItem> expenses = await expenseRepository
          .getExpenses(userId)
          .first;
      emit(ExpensesSuccess(expenses: expenses));
    } catch (error) {
      emit(ExpensesError(error: error.toString()));
    }
  }

  Future<void> _onExpenseDeleted(
    final ExpensesDeleted event,
    final Emitter<BaseState> emit,
  ) async {
    emit(ExpensesInProgress());
    try {
      await expenseRepository.deleteExpense(event.id);
      final String userId = event.userId.isNotEmpty
          ? event.userId
          : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
      final List<ExpenseItem> expenses = await expenseRepository
          .getExpenses(userId)
          .first;
      emit(ExpensesSuccess(expenses: expenses));
    } catch (error) {
      emit(ExpensesError(error: error.toString()));
    }
  }

  Future<void> _onExpenseFetched(
    final ExpensesFetched event,
    final Emitter<BaseState> emit,
  ) async {
    emit(ExpensesInProgress());
    try {
      final String userId = event.userId.isNotEmpty
          ? event.userId
          : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
      final List<ExpenseItem> expenses = await expenseRepository
          .getExpenses(userId)
          .first;
      emit(ExpensesSuccess(expenses: expenses));
    } catch (error) {
      emit(ExpensesError(error: error.toString()));
    }
  }
}
