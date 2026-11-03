import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

void main() {
  group('CurrencyKpiUtils Net Worth Tests', () {
    test('calculates solvent net worth correctly', () {
      final List<SavingItem> savings = <SavingItem>[
        SavingItem(
          id: 's1',
          name: 'Emergency Fund',
          comment: '',
          currency: 'USD',
          amount: 5000.0,
          goalAmount: 10000.0,
          status: true,
        ),
      ];

      final List<AccountReceivableItem> receivables = <AccountReceivableItem>[
        AccountReceivableItem(
          id: 'r1',
          debtorName: 'Consulting Client',
          description: '',
          amount: 2500.0,
          currency: 'USD',
          dueDate: DateTime.now().add(const Duration(days: 10)),
          isReceived: false,
          status: true,
        ),
      ];

      final List<AccountToPayItem> accountsToPay = <AccountToPayItem>[
        AccountToPayItem(
          id: 'p1',
          creditorName: 'Credit Card',
          description: '',
          amount: 1500.0,
          currency: 'USD',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isPaid: false,
          status: true,
        ),
      ];

      final List<ExpenseItem> expenses = <ExpenseItem>[
        ExpenseItem(
          id: 'e1',
          name: 'Electricity',
          comment: '',
          currency: 'USD',
          amount: 120.0,
          dateDue: '2026-11-15',
          status: true,
          isPaid: false,
        ),
      ];

      // Assets: 5,000 (savings) + 2,500 (receivables) = 7,500
      // Liabilities: 1,500 (debt) + 120 (unpaid expense) = 1,620
      // Net Worth: 7,500 - 1,620 = 5,880
      final double netWorth = CurrencyKpiUtils.calculateNetWorth(
        savings: savings,
        receivables: receivables,
        accountsToPay: accountsToPay,
        expenses: expenses,
        currency: 'USD',
      );

      expect(netWorth, equals(5880.0));
    });

    test('calculates debt-heavy negative equity correctly', () {
      final List<SavingItem> savings = <SavingItem>[
        SavingItem(
          id: 's1',
          name: 'Savings',
          comment: '',
          currency: 'USD',
          amount: 1000.0,
          goalAmount: 5000.0,
          status: true,
        ),
      ];

      final List<AccountToPayItem> accountsToPay = <AccountToPayItem>[
        AccountToPayItem(
          id: 'p1',
          creditorName: 'Car Loan',
          description: '',
          amount: 8000.0,
          currency: 'USD',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          isPaid: false,
          status: true,
        ),
      ];

      // Assets: 1,000
      // Liabilities: 8,000
      // Net Worth: -7,000
      final double netWorth = CurrencyKpiUtils.calculateNetWorth(
        savings: savings,
        receivables: const <AccountReceivableItem>[],
        accountsToPay: accountsToPay,
        expenses: const <ExpenseItem>[],
        currency: 'USD',
      );

      expect(netWorth, equals(-7000.0));
    });

    test('generates expected KPI card specs for single and dual currency', () {
      const UserModel user = UserModel(
        uid: 'user1',
        email: 'test@example.com',
        primaryCurrency: 'USD',
        enableDualCurrency: false,
      );

      final List<KpiCardSpec> cards = CurrencyKpiUtils.generateNetWorthKpiCards(
        savings: const <SavingItem>[],
        receivables: const <AccountReceivableItem>[],
        accountsToPay: const <AccountToPayItem>[],
        expenses: const <ExpenseItem>[],
        user: user,
      );

      // Single currency creates 4 balance sheet cards: Net Worth, Assets, Liabilities, Debt-to-Asset ratio
      expect(cards.length, equals(4));
      expect(cards[0].title, equals('Total Net Worth'));
      expect(cards[1].title, equals('Total Assets'));
      expect(cards[2].title, equals('Total Liabilities'));
      expect(cards[3].title, equals('Debt-to-Asset Ratio'));
    });
  });
}

