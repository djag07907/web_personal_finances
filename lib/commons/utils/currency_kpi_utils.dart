import 'package:flutter/material.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/utils/account_receivable_utils.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class KpiCardSpec {
  const KpiCardSpec({
    required this.title,
    required this.amount,
    this.subtitle,
    this.changePercent,
    this.isPositive = true,
    required this.icon,
    required this.currency,
    this.description,
    this.calculation,
  });

  final String title;
  final String amount;
  final String? subtitle;
  final String? changePercent;
  final bool isPositive;
  final IconData icon;
  final String currency;
  final String? description;
  final String? calculation;
}

class CurrencyKpiUtils {
  static const String _monthlyConversion =
      'Each active item is converted to a monthly amount: weekly × 4.33, '
      'biweekly × 2.166, monthly × 1, yearly ÷ 12, daily × 30, '
      'one-time × 1.';

  static const String _receivedDescription =
      'Money you have already collected from your active income entries.';
  static const String _receivedCalculation =
      'Sum of the amounts of all active incomes in this currency that are '
      'marked as received.';

  static const String _monthlyRateDescription =
      'Your estimated income in a typical month, based on all your active '
      'income streams regardless of whether they were received yet.';
  static const String _monthlyRateCalculation = _monthlyConversion;

  static const String _paidDescription =
      'Money you have already spent on your active expense entries.';
  static const String _paidCalculation =
      'Sum of the amounts of all active expenses in this currency that are '
      'marked as paid.';

  static const String _burnRateDescription =
      'Your estimated spending in a typical month, based on all your active '
      'expenses regardless of whether they were paid yet.';
  static const String _burnRateCalculation = _monthlyConversion;

  /// Returns currency symbol for display ('L.' for HNL, '$' for USD).
  static String getCurrencySymbol(final String currency) {
    if (currency == hnlCurrency) {
      return 'L.';
    }
    return '\$';
  }

  /// Formats an amount with its currency symbol (e.g. 'L. 1,500.00' or '$ 500.00').
  static String formatAmount(final double amount, final String currency) {
    final String symbol = getCurrencySymbol(currency);
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  static double calculateTotal<T>({
    required final List<T> items,
    required final String currency,
    required final String Function(T) getCurrency,
    required final double Function(T) getAmount,
    final bool Function(T)? getStatus,
    final bool? requiredStatus,
  }) {
    double total = 0.0;
    for (final T item in items) {
      if (getCurrency(item) == currency) {
        if (requiredStatus != null && getStatus != null) {
          if (getStatus(item) == requiredStatus) {
            total += getAmount(item);
          }
        } else {
          total += getAmount(item);
        }
      }
    }
    return total;
  }

  /// Counts items matching a specific currency and status filter.
  static int countItems<T>({
    required final List<T> items,
    required final String currency,
    required final String Function(T) getCurrency,
    required final bool Function(T) getStatus,
    required final bool requiredStatus,
  }) {
    int count = 0;
    for (final T item in items) {
      if (getCurrency(item) == currency && getStatus(item) == requiredStatus) {
        count++;
      }
    }
    return count;
  }

  /// Calculates normalized monthly income equivalent for active streams of a given currency.
  static double calculateMonthlyProjectedIncome({
    required final List<IncomeItem> items,
    required final String currency,
  }) {
    double total = 0.0;
    for (final IncomeItem item in items) {
      if (item.currency == currency && item.status) {
        switch (item.frequency) {
          case CustomFrequencyOptions.weekly:
            total += item.amount * 4.33;
            break;
          case CustomFrequencyOptions.biweekly:
            total += item.amount * 2.166;
            break;
          case CustomFrequencyOptions.monthly:
            total += item.amount;
            break;
          case CustomFrequencyOptions.yearly:
            total += item.amount / 12.0;
            break;
          case CustomFrequencyOptions.daily:
            total += item.amount * 30.0;
            break;
          case CustomFrequencyOptions.once:
            total += item.amount;
            break;
        }
      }
    }
    return total;
  }

  /// Generates scalable KPI card specs for Income items based on user dual-currency preference.
  static List<KpiCardSpec> generateIncomeKpiCards({
    required final List<IncomeItem> incomeItems,
    required final UserModel? user,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;

    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    // Primary Currency Received & Monthly Projected
    final double receivedPrimary = calculateTotal<IncomeItem>(
      items: incomeItems,
      currency: primary,
      getCurrency: (final IncomeItem item) => item.currency,
      getAmount: (final IncomeItem item) => item.amount,
      getStatus: (final IncomeItem item) => item.status && item.isReceived,
      requiredStatus: true,
    );

    final double projectedPrimary = calculateMonthlyProjectedIncome(
      items: incomeItems,
      currency: primary,
    );

    cards.add(
      KpiCardSpec(
        title: isDual ? 'Total Received ($primary)' : 'Total Received',
        amount: formatAmount(receivedPrimary, primary),
        isPositive: true,
        icon: Icons.payments_outlined,
        currency: primary,
        description: _receivedDescription,
        calculation: _receivedCalculation,
      ),
    );

    cards.add(
      KpiCardSpec(
        title: isDual ? 'Monthly Rate ($primary)' : 'Monthly Projected Rate',
        amount: formatAmount(projectedPrimary, primary),
        // subtitle: 'Normalized monthly income',
        isPositive: true,
        icon: Icons.trending_up,
        currency: primary,
        description: _monthlyRateDescription,
        calculation: _monthlyRateCalculation,
      ),
    );

    if (isDual) {
      // Secondary Currency Received & Monthly Projected
      final double receivedSecondary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: secondary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status && item.isReceived,
        requiredStatus: true,
      );

      final double projectedSecondary = calculateMonthlyProjectedIncome(
        items: incomeItems,
        currency: secondary,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received ($secondary)',
          amount: formatAmount(receivedSecondary, secondary),
          isPositive: true,
          icon: Icons.account_balance_wallet_outlined,
          currency: secondary,
          description: _receivedDescription,
          calculation: _receivedCalculation,
        ),
      );

      cards.add(
        KpiCardSpec(
          title: 'Monthly Rate ($secondary)',
          amount: formatAmount(projectedSecondary, secondary),
          // subtitle: 'Normalized monthly income',
          isPositive: true,
          icon: Icons.auto_graph,
          currency: secondary,
          description: _monthlyRateDescription,
          calculation: _monthlyRateCalculation,
        ),
      );
    }

    return cards;
  }

  /// Calculates normalized monthly expense burn rate for active expenses of a given currency.
  static double calculateMonthlyBurnRate({
    required final List<ExpenseItem> items,
    required final String currency,
  }) {
    double total = 0.0;
    for (final ExpenseItem item in items) {
      if (item.currency == currency && item.status) {
        switch (item.frequency) {
          case CustomFrequencyOptions.weekly:
            total += item.amount * 4.33;
            break;
          case CustomFrequencyOptions.biweekly:
            total += item.amount * 2.166;
            break;
          case CustomFrequencyOptions.monthly:
            total += item.amount;
            break;
          case CustomFrequencyOptions.yearly:
            total += item.amount / 12.0;
            break;
          case CustomFrequencyOptions.daily:
            total += item.amount * 30.0;
            break;
          case CustomFrequencyOptions.once:
            total += item.amount;
            break;
        }
      }
    }
    return total;
  }

  /// Generates scalable KPI card specs for Expense items based on user dual-currency preference.
  static List<KpiCardSpec> generateExpenseKpiCards({
    required final List<ExpenseItem> expenseItems,
    required final UserModel? user,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;

    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    // Primary Currency Paid & Monthly Burn Rate
    final double paidPrimary = calculateTotal<ExpenseItem>(
      items: expenseItems,
      currency: primary,
      getCurrency: (final ExpenseItem item) => item.currency,
      getAmount: (final ExpenseItem item) => item.amount,
      getStatus: (final ExpenseItem item) => item.status && item.isPaid,
      requiredStatus: true,
    );

    final double burnRatePrimary = calculateMonthlyBurnRate(
      items: expenseItems,
      currency: primary,
    );

    cards.add(
      KpiCardSpec(
        title: isDual ? 'Total Paid ($primary)' : 'Total Paid',
        amount: formatAmount(paidPrimary, primary),
        isPositive: false,
        icon: Icons.shopping_bag_outlined,
        currency: primary,
        description: _paidDescription,
        calculation: _paidCalculation,
      ),
    );

    cards.add(
      KpiCardSpec(
        title: isDual ? 'Monthly Burn Rate ($primary)' : 'Monthly Burn Rate',
        amount: formatAmount(burnRatePrimary, primary),
        isPositive: false,
        icon: Icons.trending_down,
        currency: primary,
        description: _burnRateDescription,
        calculation: _burnRateCalculation,
      ),
    );

    if (isDual) {
      // Secondary Currency Paid & Monthly Burn Rate
      final double paidSecondary = calculateTotal<ExpenseItem>(
        items: expenseItems,
        currency: secondary,
        getCurrency: (final ExpenseItem item) => item.currency,
        getAmount: (final ExpenseItem item) => item.amount,
        getStatus: (final ExpenseItem item) => item.status && item.isPaid,
        requiredStatus: true,
      );

      final double burnRateSecondary = calculateMonthlyBurnRate(
        items: expenseItems,
        currency: secondary,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Paid ($secondary)',
          amount: formatAmount(paidSecondary, secondary),
          isPositive: false,
          icon: Icons.receipt_long_outlined,
          currency: secondary,
          description: _paidDescription,
          calculation: _paidCalculation,
        ),
      );

      cards.add(
        KpiCardSpec(
          title: 'Monthly Burn Rate ($secondary)',
          amount: formatAmount(burnRateSecondary, secondary),
          isPositive: false,
          icon: Icons.analytics_outlined,
          currency: secondary,
          description: _burnRateDescription,
          calculation: _burnRateCalculation,
        ),
      );
    }

    return cards;
  }

  static const String _pendingDescription =
      'Total you still owe on your active accounts to pay, including the '
      'ones that are already overdue.';
  static const String _pendingCalculation =
      'Sum of the remaining balance of all active accounts in this currency '
      'that are not fully settled.';

  static const String _overdueDescription =
      'Part of your pending balance whose due date has already passed. '
      'These are the bills you should settle first.';
  static const String _overdueCalculation =
      'Sum of the remaining balance of all active, unsettled accounts in this '
      'currency whose due date is before today.';

  static const String _upcomingDescription =
      'Amount you will need to have available soon to cover bills that are '
      'about to be due.';
  static const String _upcomingCalculation =
      'Sum of the remaining balance of all active, unsettled accounts in this '
      'currency due from today up to the next 30 days (overdue accounts excluded).';

  static const String _paidAccountsDescription =
      'Money you have already paid towards your active accounts to pay.';
  static const String _paidAccountsCalculation =
      'Sum of all recorded payments made towards active accounts in this currency.';

  /// Generates KPI card specs for Accounts to Pay based on dual-currency preference.
  static List<KpiCardSpec> generateAccountToPayKpiCards({
    required final List<AccountToPayItem> items,
    required final UserModel? user,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;
    final List<String> currencies = <String>[primary, if (isDual) secondary];

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime limit = today.add(const Duration(days: 30));

    DateTime dateOnly(final DateTime d) => DateTime(d.year, d.month, d.day);

    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    for (final String currency in currencies) {
      final List<AccountToPayItem> active = items
          .where(
            (final AccountToPayItem item) =>
                item.status && item.currency == currency,
          )
          .toList();
      final List<AccountToPayItem> pending = active
          .where((final AccountToPayItem item) => !item.isFullyPaid)
          .toList();
      final List<AccountToPayItem> overdue = pending
          .where(
            (final AccountToPayItem item) => AccountToPayUtils.isOverdue(item),
          )
          .toList();
      final List<AccountToPayItem> upcoming = pending.where((
        final AccountToPayItem item,
      ) {
        final DateTime due = dateOnly(AccountToPayUtils.getNextDueDate(item));
        return !due.isBefore(today) && !due.isAfter(limit);
      }).toList();
      final List<AccountToPayItem> paid = active
          .where((final AccountToPayItem item) => item.isFullyPaid)
          .toList();

      double sumRemaining(final List<AccountToPayItem> list) => list.fold(
        0.0,
        (final double total, final AccountToPayItem item) =>
            total + item.remainingBalance,
      );

      final double totalPaidAmount = active.fold(
        0.0,
        (final double total, final AccountToPayItem item) =>
            total + item.totalPaid,
      );

      String suffix(final String label) =>
          isDual ? '$label ($currency)' : label;

      cards.add(
        KpiCardSpec(
          title: suffix('Total Pending'),
          amount: formatAmount(sumRemaining(pending), currency),
          subtitle: '${pending.length} outstanding',
          isPositive: false,
          icon: Icons.hourglass_bottom_outlined,
          currency: currency,
          description: _pendingDescription,
          calculation: _pendingCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Overdue'),
          amount: formatAmount(sumRemaining(overdue), currency),
          subtitle: '${overdue.length} past due date',
          isPositive: false,
          icon: Icons.warning_amber_rounded,
          currency: currency,
          description: _overdueDescription,
          calculation: _overdueCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Due in 30 Days'),
          amount: formatAmount(sumRemaining(upcoming), currency),
          subtitle: '${upcoming.length} upcoming',
          isPositive: false,
          icon: Icons.event_outlined,
          currency: currency,
          description: _upcomingDescription,
          calculation: _upcomingCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Total Paid'),
          amount: formatAmount(totalPaidAmount, currency),
          subtitle: '${paid.length} settled',
          isPositive: true,
          icon: Icons.check_circle_outline,
          currency: currency,
          description: _paidAccountsDescription,
          calculation: _paidAccountsCalculation,
        ),
      );
    }

    return cards;
  }

  static const String _receivablePendingDescription =
      'Total money owed to you from your active accounts receivable, including overdue items.';
  static const String _receivablePendingCalculation =
      'Sum of the remaining balance of all active receivable accounts in this currency that are not fully settled.';

  static const String _receivableOverdueDescription =
      'Pending payments owed to you whose due date has already passed. Follow up on these first.';
  static const String _receivableOverdueCalculation =
      'Sum of the remaining balance of all active, unsettled receivable accounts in this currency whose due date is before today.';

  static const String _receivableUpcomingDescription =
      'Amount expected to be collected soon from receivables due in the next 30 days.';
  static const String _receivableUpcomingCalculation =
      'Sum of the remaining balance of all active, unsettled receivable accounts in this currency due from today up to the next 30 days (overdue accounts excluded).';

  static const String _receivableCollectedDescription =
      'Money you have already collected from your active accounts receivable.';
  static const String _receivableCollectedCalculation =
      'Sum of all recorded payments collected towards active accounts receivable in this currency.';

  /// Generates KPI card specs for Accounts Receivable based on dual-currency preference.
  static List<KpiCardSpec> generateAccountReceivableKpiCards({
    required final List<AccountReceivableItem> items,
    required final UserModel? user,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;
    final List<String> currencies = <String>[primary, if (isDual) secondary];

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime limit = today.add(const Duration(days: 30));

    DateTime dateOnly(final DateTime d) => DateTime(d.year, d.month, d.day);

    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    for (final String currency in currencies) {
      final List<AccountReceivableItem> active = items
          .where(
            (final AccountReceivableItem item) =>
                item.status && item.currency == currency,
          )
          .toList();
      final List<AccountReceivableItem> pending = active
          .where((final AccountReceivableItem item) => !item.isFullyPaid)
          .toList();
      final List<AccountReceivableItem> overdue = pending
          .where(
            (final AccountReceivableItem item) =>
                AccountReceivableUtils.isOverdue(item),
          )
          .toList();
      final List<AccountReceivableItem> upcoming = pending.where((
        final AccountReceivableItem item,
      ) {
        final DateTime due = dateOnly(
          AccountReceivableUtils.getNextDueDate(item),
        );
        return !due.isBefore(today) && !due.isAfter(limit);
      }).toList();
      final List<AccountReceivableItem> paid = active
          .where((final AccountReceivableItem item) => item.isFullyPaid)
          .toList();

      double sumRemaining(final List<AccountReceivableItem> list) => list.fold(
        0.0,
        (final double total, final AccountReceivableItem item) =>
            total + item.remainingBalance,
      );

      final double totalCollectedAmount = active.fold(
        0.0,
        (final double total, final AccountReceivableItem item) =>
            total + item.totalCollected,
      );

      String suffix(final String label) =>
          isDual ? '$label ($currency)' : label;

      cards.add(
        KpiCardSpec(
          title: suffix('Total Pending'),
          amount: formatAmount(sumRemaining(pending), currency),
          subtitle: '${pending.length} outstanding',
          isPositive: false,
          icon: Icons.hourglass_top_outlined,
          currency: currency,
          description: _receivablePendingDescription,
          calculation: _receivablePendingCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Overdue'),
          amount: formatAmount(sumRemaining(overdue), currency),
          subtitle: '${overdue.length} past due date',
          isPositive: false,
          icon: Icons.warning_amber_rounded,
          currency: currency,
          description: _receivableOverdueDescription,
          calculation: _receivableOverdueCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Due in 30 Days'),
          amount: formatAmount(sumRemaining(upcoming), currency),
          subtitle: '${upcoming.length} upcoming',
          isPositive: true,
          icon: Icons.event_available_outlined,
          currency: currency,
          description: _receivableUpcomingDescription,
          calculation: _receivableUpcomingCalculation,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix('Total Collected'),
          amount: formatAmount(totalCollectedAmount, currency),
          subtitle: '${paid.length} settled',
          isPositive: true,
          icon: Icons.check_circle_outline,
          currency: currency,
          description: _receivableCollectedDescription,
          calculation: _receivableCollectedCalculation,
        ),
      );
    }

    return cards;
  }
}
