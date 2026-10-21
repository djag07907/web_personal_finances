import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/repository/accounts_receivable_repository.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/repository/accounts_to_pay_repository.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/expenses/repository/expenses_repository.dart';
import 'package:web_personal_finances/home/bloc/home_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_event.dart';
import 'package:web_personal_finances/home/bloc/home_state.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class FakeUserRepository implements UserRepository {
  final UserModel? userToReturn;
  FakeUserRepository({this.userToReturn});

  @override
  Future<UserModel?> getUser(final String uid) async => userToReturn;

  @override
  Future<void> saveUser(final UserModel user) async {}

  @override
  Stream<UserModel?> streamUser(final String uid) =>
      Stream<UserModel?>.value(userToReturn);
}

class FakeIncomeRepository implements IncomeRepository {
  final StreamController<List<IncomeItem>> _controller =
      StreamController<List<IncomeItem>>.broadcast();

  void emitIncomes(final List<IncomeItem> incomes) => _controller.add(incomes);

  @override
  Stream<List<IncomeItem>> getIncomes(final String userId) =>
      _controller.stream;

  @override
  Future<void> addIncome(final IncomeItem item) async {}

  @override
  Future<void> updateIncome(final IncomeItem item) async {}

  @override
  Future<void> deleteIncome(final String id) async {}
}

class FakeExpenseRepository implements ExpenseRepository {
  final StreamController<List<ExpenseItem>> _controller =
      StreamController<List<ExpenseItem>>.broadcast();

  void emitExpenses(final List<ExpenseItem> expenses) =>
      _controller.add(expenses);

  @override
  Stream<List<ExpenseItem>> getExpenses(final String userId) =>
      _controller.stream;

  @override
  Future<void> addExpense(final ExpenseItem item) async {}

  @override
  Future<void> updateExpense(final ExpenseItem item) async {}

  @override
  Future<void> deleteExpense(final String id) async {}
}

class FakeAccountToPayRepository implements AccountToPayRepository {
  final StreamController<List<AccountToPayItem>> _controller =
      StreamController<List<AccountToPayItem>>.broadcast();

  void emitAccounts(final List<AccountToPayItem> items) =>
      _controller.add(items);

  @override
  Stream<List<AccountToPayItem>> getAccountsToPay(final String userId) =>
      _controller.stream;

  @override
  Future<void> addAccountToPay(final AccountToPayItem item) async {}

  @override
  Future<void> updateAccountToPay(final AccountToPayItem item) async {}

  @override
  Future<void> deleteAccountToPay(final String id) async {}
}

class FakeAccountReceivableRepository implements AccountReceivableRepository {
  final StreamController<List<AccountReceivableItem>> _controller =
      StreamController<List<AccountReceivableItem>>.broadcast();

  void emitAccounts(final List<AccountReceivableItem> items) =>
      _controller.add(items);

  @override
  Stream<List<AccountReceivableItem>> getAccountsReceivable(
    final String userId,
  ) => _controller.stream;

  @override
  Future<void> addAccountReceivable(final AccountReceivableItem item) async {}

  @override
  Future<void> updateAccountReceivable(
    final AccountReceivableItem item,
  ) async {}

  @override
  Future<void> deleteAccountReceivable(final String id) async {}
}

void main() {
  group('HomeBloc Tests', () {
    late FakeUserRepository fakeUserRepo;
    late FakeIncomeRepository fakeIncomeRepo;
    late FakeExpenseRepository fakeExpenseRepo;
    late FakeAccountToPayRepository fakePayRepo;
    late FakeAccountReceivableRepository fakeReceivableRepo;
    late HomeBloc homeBloc;

    final UserModel mockUser = UserModel(
      uid: 'user123',
      email: 'test@example.com',
      fullName: 'John Doe',
      primaryCurrency: 'HNL',
    );

    setUp(() {
      fakeUserRepo = FakeUserRepository(userToReturn: mockUser);
      fakeIncomeRepo = FakeIncomeRepository();
      fakeExpenseRepo = FakeExpenseRepository();
      fakePayRepo = FakeAccountToPayRepository();
      fakeReceivableRepo = FakeAccountReceivableRepository();

      homeBloc = HomeBloc(
        userRepository: fakeUserRepo,
        incomeRepository: fakeIncomeRepo,
        expenseRepository: fakeExpenseRepo,
        accountToPayRepository: fakePayRepo,
        accountReceivableRepository: fakeReceivableRepo,
      );
    });

    tearDown(() {
      homeBloc.close();
    });

    test('Initial state is HomeInitial', () {
      expect(homeBloc.state, equals(HomeInitial()));
    });

    test(
      'HomeFetchProfile loads user and listens to reactive streams',
      () async {
        final List<HomeState> states = <HomeState>[];
        final StreamSubscription<HomeState> sub = homeBloc.stream.listen(
          states.add,
        );

        homeBloc.add(const HomeFetchProfile(uid: 'user123'));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], equals(HomeLoading()));
        expect(states[1], isA<HomeLoaded>());

        final HomeLoaded loaded = states[1] as HomeLoaded;
        expect(loaded.profile.fullName, equals('John Doe'));
        expect(loaded.incomes, isEmpty);
        expect(loaded.expenses, isEmpty);
        expect(loaded.accountsToPay, isEmpty);
        expect(loaded.accountsReceivable, isEmpty);

        // Now emit an income
        final IncomeItem testIncome = IncomeItem(
          id: 'inc1',
          name: 'Salary',
          comment: '',
          currency: 'HNL',
          amount: 25000,
          frequency: CustomFrequencyOptions.monthly,
          dateToReceive: '2026-10-30',
          status: true,
        );
        fakeIncomeRepo.emitIncomes(<IncomeItem>[testIncome]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final HomeLoaded stateAfterIncome = homeBloc.state as HomeLoaded;
        expect(stateAfterIncome.incomes.length, equals(1));
        expect(stateAfterIncome.incomes.first.name, equals('Salary'));

        // Now emit an expense
        final ExpenseItem testExpense = ExpenseItem(
          id: 'exp1',
          name: 'Groceries',
          comment: '',
          currency: 'HNL',
          amount: 5000,
          dateDue: '2026-10-25',
          status: true,
        );
        fakeExpenseRepo.emitExpenses(<ExpenseItem>[testExpense]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final HomeLoaded stateAfterExpense = homeBloc.state as HomeLoaded;
        expect(stateAfterExpense.expenses.length, equals(1));
        expect(stateAfterExpense.expenses.first.name, equals('Groceries'));

        // Now emit an account to pay
        final AccountToPayItem testPay = AccountToPayItem(
          id: 'pay1',
          creditorName: 'Bank Loan',
          description: 'Auto loan',
          amount: 15000,
          currency: 'HNL',
          dueDate: DateTime.now().add(const Duration(days: 10)),
        );
        fakePayRepo.emitAccounts(<AccountToPayItem>[testPay]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final HomeLoaded stateAfterPay = homeBloc.state as HomeLoaded;
        expect(stateAfterPay.accountsToPay.length, equals(1));
        expect(
          stateAfterPay.accountsToPay.first.creditorName,
          equals('Bank Loan'),
        );

        // Now emit an account receivable
        final AccountReceivableItem testReceivable = AccountReceivableItem(
          id: 'rec1',
          debtorName: 'Alice',
          description: 'Friend loan',
          amount: 3000,
          currency: 'HNL',
          dueDate: DateTime.now().add(const Duration(days: 5)),
        );
        fakeReceivableRepo.emitAccounts(<AccountReceivableItem>[
          testReceivable,
        ]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final HomeLoaded stateAfterReceivable = homeBloc.state as HomeLoaded;
        expect(stateAfterReceivable.accountsReceivable.length, equals(1));
        expect(
          stateAfterReceivable.accountsReceivable.first.debtorName,
          equals('Alice'),
        );

        await sub.cancel();
      },
    );
  });
}
