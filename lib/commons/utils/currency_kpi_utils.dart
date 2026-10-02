import 'package:flutter/material.dart';
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

    if (isDual) {
      // Primary Currency Received
      final double receivedPrimary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: true,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received ($primary)',
          amount: formatAmount(receivedPrimary, primary),
          isPositive: true,
          icon: Icons.payments,
          currency: primary,
        ),
      );

      // Secondary Currency Received
      final double receivedSecondary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: secondary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: true,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received ($secondary)',
          amount: formatAmount(receivedSecondary, secondary),
          isPositive: true,
          icon: Icons.account_balance_wallet,
          currency: secondary,
        ),
      );
    } else {
      final double received = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: true,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received',
          amount: formatAmount(received, primary),
          isPositive: true,
          icon: Icons.payments,
          currency: primary,
        ),
      );
    }

    return cards;
  }
}
