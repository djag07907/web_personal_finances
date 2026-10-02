import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
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
  });

  final String title;
  final String amount;
  final String? subtitle;
  final String? changePercent;
  final bool isPositive;
  final IconData icon;
  final String currency;
}

/// Scalable utility for calculating financial summaries and generating
/// KPI card specifications across currencies and financial flows.
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
        ),
      );
    }

    return cards;
  }
}
