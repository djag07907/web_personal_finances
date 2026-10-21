import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/repository/accounts_receivable_repository.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/repository/accounts_to_pay_repository.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/expenses/repository/expenses_repository.dart';
import 'package:web_personal_finances/home/bloc/home_event.dart';
import 'package:web_personal_finances/home/bloc/home_state.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this.userRepository,
    final IncomeRepository? incomeRepository,
    final ExpenseRepository? expenseRepository,
    final AccountToPayRepository? accountToPayRepository,
    final AccountReceivableRepository? accountReceivableRepository,
  }) : incomeRepository = incomeRepository ?? IncomeRepository(),
       expenseRepository = expenseRepository ?? ExpenseRepository(),
       accountToPayRepository =
           accountToPayRepository ?? AccountToPayRepository(),
       accountReceivableRepository =
           accountReceivableRepository ?? AccountReceivableRepository(),
       super(HomeInitial()) {
    on<HomeFetchProfile>(_onFetchProfile);
    on<HomeIncomesUpdated>(_onIncomesUpdated);
    on<HomeExpensesUpdated>(_onExpensesUpdated);
    on<HomeAccountsToPayUpdated>(_onAccountsToPayUpdated);
    on<HomeAccountsReceivableUpdated>(_onAccountsReceivableUpdated);
  }

  final UserRepository userRepository;
  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;
  final AccountToPayRepository accountToPayRepository;
  final AccountReceivableRepository accountReceivableRepository;

  StreamSubscription<List<IncomeItem>>? _incomesSubscription;
  StreamSubscription<List<ExpenseItem>>? _expensesSubscription;
  StreamSubscription<List<AccountToPayItem>>? _accountsToPaySubscription;
  StreamSubscription<List<AccountReceivableItem>>?
  _accountsReceivableSubscription;

  Future<void> _onFetchProfile(
    final HomeFetchProfile event,
    final Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final UserModel? profile = await userRepository.getUser(event.uid);
      final UserModel resolvedProfile =
          profile ?? UserModel(uid: event.uid, email: emptyString);

      emit(HomeLoaded(profile: resolvedProfile));

      await _incomesSubscription?.cancel();
      await _expensesSubscription?.cancel();
      await _accountsToPaySubscription?.cancel();
      await _accountsReceivableSubscription?.cancel();

      _incomesSubscription = incomeRepository.getIncomes(event.uid).listen((
        final List<IncomeItem> incomes,
      ) {
        add(HomeIncomesUpdated(incomes: incomes));
      });

      _expensesSubscription = expenseRepository.getExpenses(event.uid).listen((
        final List<ExpenseItem> expenses,
      ) {
        add(HomeExpensesUpdated(expenses: expenses));
      });

      _accountsToPaySubscription = accountToPayRepository
          .getAccountsToPay(event.uid)
          .listen((final List<AccountToPayItem> accountsToPay) {
            add(HomeAccountsToPayUpdated(accountsToPay: accountsToPay));
          });

      _accountsReceivableSubscription = accountReceivableRepository
          .getAccountsReceivable(event.uid)
          .listen((final List<AccountReceivableItem> accountsReceivable) {
            add(
              HomeAccountsReceivableUpdated(
                accountsReceivable: accountsReceivable,
              ),
            );
          });
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void _onIncomesUpdated(
    final HomeIncomesUpdated event,
    final Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(incomes: event.incomes));
    }
  }

  void _onExpensesUpdated(
    final HomeExpensesUpdated event,
    final Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(expenses: event.expenses));
    }
  }

  void _onAccountsToPayUpdated(
    final HomeAccountsToPayUpdated event,
    final Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(accountsToPay: event.accountsToPay));
    }
  }

  void _onAccountsReceivableUpdated(
    final HomeAccountsReceivableUpdated event,
    final Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      emit(
        (state as HomeLoaded).copyWith(
          accountsReceivable: event.accountsReceivable,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _incomesSubscription?.cancel();
    _expensesSubscription?.cancel();
    _accountsToPaySubscription?.cancel();
    _accountsReceivableSubscription?.cancel();
    return super.close();
  }
}
