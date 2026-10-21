import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/saving_utils.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

void main() {
  group('SavingItem Model & Financial Computations', () {
    test('Calculates currentAmount with initial amount, deposits and withdrawals', () {
      final DateTime now = DateTime.now();
      final SavingRegistryItem deposit1 = SavingRegistryItem(
        id: 'tx1',
        savingId: 's1',
        amount: 200.0,
        type: CustomSavingTransactionType.deposit,
        date: now,
        createdDate: now,
      );
      final SavingRegistryItem deposit2 = SavingRegistryItem(
        id: 'tx2',
        savingId: 's1',
        amount: 300.0,
        type: CustomSavingTransactionType.deposit,
        date: now,
        createdDate: now,
      );
      final SavingRegistryItem withdrawal = SavingRegistryItem(
        id: 'tx3',
        savingId: 's1',
        amount: 150.0,
        type: CustomSavingTransactionType.withdrawal,
        date: now,
        createdDate: now,
      );

      final SavingItem item = SavingItem(
        id: 's1',
        name: 'Emergency Fund',
        comment: 'For rainy days',
        currency: usdCurrency,
        amount: 500.0, // initial amount
        goalAmount: 2000.0,
        status: true,
        category: CustomSavingCategoryOptions.emergencyFund,
        registries: <SavingRegistryItem>[deposit1, deposit2, withdrawal],
      );

      // 500 initial + 200 + 300 - 150 = 850
      expect(item.currentAmount, 850.0);
      expect(item.remainingAmount, 1150.0);
      expect(item.progressPercent, closeTo(42.5, 0.01));
      expect(item.isCompleted, isFalse);
    });

    test('Marks as completed when currentAmount meets or exceeds goalAmount', () {
      final DateTime now = DateTime.now();
      final SavingRegistryItem deposit = SavingRegistryItem(
        id: 'tx1',
        savingId: 's2',
        amount: 2000.0,
        type: CustomSavingTransactionType.deposit,
        date: now,
        createdDate: now,
      );

      final SavingItem item = SavingItem(
        id: 's2',
        name: 'MacBook Pro',
        comment: 'Upgrade laptop',
        currency: usdCurrency,
        amount: 500.0,
        goalAmount: 2500.0,
        status: true,
        category: CustomSavingCategoryOptions.tech,
        registries: <SavingRegistryItem>[deposit],
      );

      expect(item.currentAmount, 2500.0);
      expect(item.remainingAmount, 0.0);
      expect(item.progressPercent, 100.0);
      expect(item.isCompleted, isTrue);
    });

    test('Calculates requiredMonthlyContribution correctly for future target dates', () {
      final DateTime now = DateTime.now();
      final DateTime futureDate = DateTime(now.year, now.month + 3, now.day); // exactly 3 months

      final SavingItem item = SavingItem(
        id: 's3',
        name: 'Vacation',
        comment: 'Summer trip',
        currency: hnlCurrency,
        amount: 1000.0,
        goalAmount: 4000.0, // 3000 remaining
        status: true,
        targetDate: futureDate,
        category: CustomSavingCategoryOptions.vacation,
      );

      expect(item.remainingAmount, 3000.0);
      expect(item.requiredMonthlyContribution, greaterThan(0.0));
      // 3000 remaining / ~3 months = approx 1000/mo
      expect(item.requiredMonthlyContribution, closeTo(1000.0, 100.0));
    });

    test('Serialization roundtrip preserves all fields', () {
      final DateTime now = DateTime(2026, 6, 15);
      final SavingRegistryItem tx = SavingRegistryItem(
        id: 'tx99',
        savingId: 's99',
        amount: 500.0,
        type: CustomSavingTransactionType.deposit,
        date: now,
        createdDate: now,
        comment: 'Bonus added',
      );

      final SavingItem original = SavingItem(
        id: 's99',
        name: 'Apartment Downpayment',
        comment: 'Building capital',
        currency: hnlCurrency,
        amount: 10000.0,
        goalAmount: 50000.0,
        status: true,
        category: CustomSavingCategoryOptions.realEstate,
        targetDate: DateTime(2028, 12, 31),
        tags: <String>['real_estate', 'priority'],
        registries: <SavingRegistryItem>[tx],
      );

      final Map<String, dynamic> map = original.toMap();
      final SavingItem restored = SavingItem.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.comment, original.comment);
      expect(restored.currency, original.currency);
      expect(restored.amount, original.amount);
      expect(restored.goalAmount, original.goalAmount);
      expect(restored.category, original.category);
      expect(restored.tags, original.tags);
      expect(restored.registries.length, 1);
      expect(restored.registries.first.amount, 500.0);
      expect(restored.registries.first.comment, 'Bonus added');
    });
  });

  group('SavingUtils Financial Aggregators', () {
    final DateTime now = DateTime.now();
    final List<SavingItem> sampleItems = <SavingItem>[
      SavingItem(
        id: '1',
        name: 'HNL Goal 1',
        comment: 'Emergency',
        currency: hnlCurrency,
        amount: 1000.0,
        goalAmount: 5000.0,
        status: true,
        category: CustomSavingCategoryOptions.emergencyFund,
        registries: <SavingRegistryItem>[
          SavingRegistryItem(
            id: 't1',
            savingId: '1',
            amount: 500.0,
            type: CustomSavingTransactionType.deposit,
            date: now,
            createdDate: now,
          ),
        ],
      ),
      SavingItem(
        id: '2',
        name: 'HNL Goal 2',
        comment: 'Vehicle',
        currency: hnlCurrency,
        amount: 2000.0,
        goalAmount: 10000.0,
        status: true,
        category: CustomSavingCategoryOptions.vehicle,
      ),
      SavingItem(
        id: '3',
        name: 'USD Goal 1',
        comment: 'Tech',
        currency: usdCurrency,
        amount: 300.0,
        goalAmount: 1000.0,
        status: true,
        category: CustomSavingCategoryOptions.tech,
      ),
      SavingItem(
        id: '4',
        name: 'Inactive Goal',
        comment: 'Other',
        currency: hnlCurrency,
        amount: 5000.0,
        goalAmount: 5000.0,
        status: false,
        category: CustomSavingCategoryOptions.other,
      ),
    ];

    test('calculateTotalSaved ignores inactive goals and filters by currency', () {
      // HNL active: (1000 + 500) + 2000 = 3500
      final double totalHnl = SavingUtils.calculateTotalSaved(sampleItems, hnlCurrency);
      expect(totalHnl, 3500.0);

      // USD active: 300
      final double totalUsd = SavingUtils.calculateTotalSaved(sampleItems, usdCurrency);
      expect(totalUsd, 300.0);
    });

    test('calculateTotalGoal ignores inactive goals and filters by currency', () {
      // HNL active: 5000 + 10000 = 15000
      final double totalGoalHnl = SavingUtils.calculateTotalGoal(sampleItems, hnlCurrency);
      expect(totalGoalHnl, 15000.0);

      // USD active: 1000
      final double totalGoalUsd = SavingUtils.calculateTotalGoal(sampleItems, usdCurrency);
      expect(totalGoalUsd, 1000.0);
    });

    test('calculateOverallProgress returns correct percentage', () {
      // HNL: (3500 / 15000) * 100 = 23.33%
      final double progressHnl =
          SavingUtils.calculateOverallProgress(sampleItems, hnlCurrency);
      expect(progressHnl, closeTo(23.33, 0.05));

      // USD: (300 / 1000) * 100 = 30.0%
      final double progressUsd =
          SavingUtils.calculateOverallProgress(sampleItems, usdCurrency);
      expect(progressUsd, closeTo(30.0, 0.05));
    });
  });

  group('CurrencyKpiUtils Savings Card Generation', () {
    final List<SavingItem> items = <SavingItem>[
      SavingItem(
        id: '1',
        name: 'Emergency Fund',
        comment: 'Fund',
        currency: hnlCurrency,
        amount: 2000.0,
        goalAmount: 10000.0,
        status: true,
        category: CustomSavingCategoryOptions.emergencyFund,
      ),
      SavingItem(
        id: '2',
        name: 'Crypto & ETFs',
        comment: 'Invest',
        currency: usdCurrency,
        amount: 500.0,
        goalAmount: 2000.0,
        status: true,
        category: CustomSavingCategoryOptions.investment,
      ),
    ];

    test('Generates 4 KPI cards for single currency user', () {
      final UserModel user = UserModel(
        uid: 'user1',
        email: 'test@example.com',
        primaryCurrency: hnlCurrency,
        enableDualCurrency: false,
      );

      final List<KpiCardSpec> cards = CurrencyKpiUtils.generateSavingKpiCards(
        items: items,
        user: user,
      );

      expect(cards.length, 4);
      expect(cards[0].title, 'Total Saved');
      expect(cards[0].amount, contains('L.'));
      expect(cards[1].title, 'Total Goal Target');
      expect(cards[2].title, 'Global Progress');
      expect(cards[3].title, 'Monthly Commitment');
    });

    test('Generates 8 KPI cards for dual currency user', () {
      final UserModel user = UserModel(
        uid: 'user2',
        email: 'test@example.com',
        primaryCurrency: hnlCurrency,
        enableDualCurrency: true,
      );

      final List<KpiCardSpec> cards = CurrencyKpiUtils.generateSavingKpiCards(
        items: items,
        user: user,
      );

      expect(cards.length, 8);
      // 4 cards for HNL + 4 cards for USD
      expect(cards.any((final KpiCardSpec c) => c.title.contains('(HNL)')), isTrue);
      expect(cards.any((final KpiCardSpec c) => c.title.contains('(USD)')), isTrue);
    });
  });
}
