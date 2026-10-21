import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/utils/account_receivable_utils.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/commons/utils/saving_utils.dart';
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
    final BuildContext? context,
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

    String suffix(final String label, final String curr) =>
        isDual ? '$label ($curr)' : label;

    cards.add(
      KpiCardSpec(
        title: suffix(context!.translate('total_received'), primary),
        amount: formatAmount(receivedPrimary, primary),
        isPositive: true,
        icon: Icons.payments_outlined,
        currency: primary,
        description: context.translate('income_received_desc'),
        calculation: context.translate('income_received_calc'),
      ),
    );

    cards.add(
      KpiCardSpec(
        title: suffix(
          context.translate(isDual ? 'monthly_rate' : 'monthly_projected_rate'),
          primary,
        ),
        amount: formatAmount(projectedPrimary, primary),
        isPositive: true,
        icon: Icons.trending_up,
        currency: primary,
        description: context.translate('income_monthly_rate_desc'),
        calculation: context.translate('monthly_conversion_calc'),
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
          title: suffix(context.translate('total_received'), secondary),
          amount: formatAmount(receivedSecondary, secondary),
          isPositive: true,
          icon: Icons.account_balance_wallet_outlined,
          currency: secondary,
          description: context.translate('income_received_desc'),
          calculation: context.translate('income_received_calc'),
        ),
      );

      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('monthly_rate'), secondary),
          amount: formatAmount(projectedSecondary, secondary),
          isPositive: true,
          icon: Icons.auto_graph,
          currency: secondary,
          description: context.translate('income_monthly_rate_desc'),
          calculation: context.translate('monthly_conversion_calc'),
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
    final BuildContext? context,
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

    String suffix(final String label, final String curr) =>
        isDual ? '$label ($curr)' : label;

    cards.add(
      KpiCardSpec(
        title: suffix(context!.translate('total_paid'), primary),
        amount: formatAmount(paidPrimary, primary),
        isPositive: false,
        icon: Icons.shopping_bag_outlined,
        currency: primary,
        description: context.translate('expense_paid_desc'),
        calculation: context.translate('expense_paid_calc'),
      ),
    );

    cards.add(
      KpiCardSpec(
        title: suffix(context.translate('monthly_burn_rate'), primary),
        amount: formatAmount(burnRatePrimary, primary),
        isPositive: false,
        icon: Icons.trending_down,
        currency: primary,
        description: context.translate('expense_burn_rate_desc'),
        calculation: context.translate('monthly_conversion_calc'),
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
          title: suffix(context.translate('total_paid'), secondary),
          amount: formatAmount(paidSecondary, secondary),
          isPositive: false,
          icon: Icons.receipt_long_outlined,
          currency: secondary,
          description: context.translate('expense_paid_desc'),
          calculation: context.translate('expense_paid_calc'),
        ),
      );

      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('monthly_burn_rate'), secondary),
          amount: formatAmount(burnRateSecondary, secondary),
          isPositive: false,
          icon: Icons.analytics_outlined,
          currency: secondary,
          description: context.translate('expense_burn_rate_desc'),
          calculation: context.translate('monthly_conversion_calc'),
        ),
      );
    }

    return cards;
  }

  /// Generates KPI card specs for Accounts to Pay based on dual-currency preference.
  static List<KpiCardSpec> generateAccountToPayKpiCards({
    required final List<AccountToPayItem> items,
    required final UserModel? user,
    final BuildContext? context,
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
          title: suffix(context!.translate('total_pending')),
          amount: formatAmount(sumRemaining(pending), currency),
          subtitle: '${pending.length} ${context.translate('outstanding')}',
          isPositive: false,
          icon: Icons.hourglass_bottom_outlined,
          currency: currency,
          description: context.translate('accounts_to_pay_pending_desc'),
          calculation: context.translate('accounts_to_pay_pending_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('overdue')),
          amount: formatAmount(sumRemaining(overdue), currency),
          subtitle: '${overdue.length} ${context.translate('past_due_date')}',
          isPositive: false,
          icon: Icons.warning_amber_rounded,
          currency: currency,
          description: context.translate('accounts_to_pay_overdue_desc'),
          calculation: context.translate('accounts_to_pay_overdue_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('due_in_30_days')),
          amount: formatAmount(sumRemaining(upcoming), currency),
          subtitle: '${upcoming.length} ${context.translate('upcoming')}',
          isPositive: false,
          icon: Icons.event_outlined,
          currency: currency,
          description: context.translate('accounts_to_pay_upcoming_desc'),
          calculation: context.translate('accounts_to_pay_upcoming_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('total_paid')),
          amount: formatAmount(totalPaidAmount, currency),
          subtitle: '${paid.length} ${context.translate('settled')}',
          isPositive: true,
          icon: Icons.check_circle_outline,
          currency: currency,
          description: context.translate('accounts_to_pay_paid_desc'),
          calculation: context.translate('accounts_to_pay_paid_calc'),
        ),
      );
    }

    return cards;
  }

  /// Generates KPI card specs for Accounts Receivable based on dual-currency preference.
  static List<KpiCardSpec> generateAccountReceivableKpiCards({
    required final List<AccountReceivableItem> items,
    required final UserModel? user,
    final BuildContext? context,
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
          title: suffix(context!.translate('total_pending')),
          amount: formatAmount(sumRemaining(pending), currency),
          subtitle: '${pending.length} ${context.translate('outstanding')}',
          isPositive: false,
          icon: Icons.hourglass_top_outlined,
          currency: currency,
          description: context.translate('accounts_receivable_pending_desc'),
          calculation: context.translate('accounts_receivable_pending_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('overdue')),
          amount: formatAmount(sumRemaining(overdue), currency),
          subtitle: '${overdue.length} ${context.translate('past_due_date')}',
          isPositive: false,
          icon: Icons.warning_amber_rounded,
          currency: currency,
          description: context.translate('accounts_receivable_overdue_desc'),
          calculation: context.translate('accounts_receivable_overdue_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('due_in_30_days')),
          amount: formatAmount(sumRemaining(upcoming), currency),
          subtitle: '${upcoming.length} ${context.translate('upcoming')}',
          isPositive: true,
          icon: Icons.event_available_outlined,
          currency: currency,
          description: context.translate('accounts_receivable_upcoming_desc'),
          calculation: context.translate('accounts_receivable_upcoming_calc'),
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('total_collected')),
          amount: formatAmount(totalCollectedAmount, currency),
          subtitle: '${paid.length} ${context.translate('settled')}',
          isPositive: true,
          icon: Icons.check_circle_outline,
          currency: currency,
          description: context.translate('accounts_receivable_collected_desc'),
          calculation: context.translate('accounts_receivable_collected_calc'),
        ),
      );
    }

    return cards;
  }

  static List<KpiCardSpec> generateSavingKpiCards({
    required final List<SavingItem> items,
    final UserModel? user,
    final BuildContext? context,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;
    final List<String> currencies = <String>[primary, if (isDual) secondary];
    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    for (final String currency in currencies) {
      final List<SavingItem> active = items
          .where((final SavingItem i) => i.status && i.currency == currency)
          .toList();

      final double totalSaved = SavingUtils.calculateTotalSaved(
        items,
        currency,
      );
      final double totalGoal = SavingUtils.calculateTotalGoal(items, currency);
      final double overallProgress = SavingUtils.calculateOverallProgress(
        items,
        currency,
      );
      final double monthlyContribution =
          SavingUtils.calculateTotalMonthlyContribution(items, currency);

      final int completedCount = active
          .where((final SavingItem i) => i.isCompleted)
          .length;

      String suffix(final String label) =>
          isDual ? '$label ($currency)' : label;

      final String totalSavedTitle = context!.translate('total_savings');
      final String totalSavedSubtitle =
          '${active.length} ${context.translate('active_goals')}';
      final String totalSavedDesc = context.translate('total_savings_desc');
      final String totalSavedCalc = context.translate('total_savings_calc');

      final String totalGoalTitle = context.translate('total_goal_amount');
      final String totalGoalSubtitle =
          '$completedCount ${context.translate('reached')}';
      final String totalGoalDesc = context.translate('total_goal_desc');
      final String totalGoalCalc = context.translate('total_goal_calc');

      final String progressTitle = context.translate('overall_progress');
      final String progressSubtitle =
          '$completedCount ${context.translate('of')} ${active.length} ${context.translate('completed')}';
      final String progressDesc = context.translate('overall_progress_desc');
      final String progressCalc = context.translate('overall_progress_calc');

      final String monthlyTitle = context.translate(
        'monthly_contribution_needed',
      );
      final String monthlySubtitle = context.translate(
        'to_meet_deadlines_on_time',
      );
      final String monthlyDesc = context.translate('monthly_contribution_desc');
      final String monthlyCalc = context.translate('monthly_contribution_calc');

      cards.add(
        KpiCardSpec(
          title: suffix(totalSavedTitle),
          amount: formatAmount(totalSaved, currency),
          subtitle: totalSavedSubtitle,
          isPositive: true,
          icon: Icons.savings_outlined,
          currency: currency,
          description: totalSavedDesc,
          calculation: totalSavedCalc,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(totalGoalTitle),
          amount: formatAmount(totalGoal, currency),
          subtitle: totalGoalSubtitle,
          isPositive: true,
          icon: Icons.flag_outlined,
          currency: currency,
          description: totalGoalDesc,
          calculation: totalGoalCalc,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(progressTitle),
          amount: '${overallProgress.toStringAsFixed(1)}%',
          subtitle: progressSubtitle,
          isPositive: overallProgress >= 50,
          icon: Icons.donut_large_outlined,
          currency: currency,
          description: progressDesc,
          calculation: progressCalc,
        ),
      );
      cards.add(
        KpiCardSpec(
          title: suffix(monthlyTitle),
          amount: formatAmount(monthlyContribution, currency),
          subtitle: monthlySubtitle,
          isPositive: true,
          icon: Icons.calendar_month_outlined,
          currency: currency,
          description: monthlyDesc,
          calculation: monthlyCalc,
        ),
      );
    }

    return cards;
  }
}
