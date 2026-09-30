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
      // Primary Currency Received & Pending
      final double receivedPrimary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: true,
      );
      final double pendingPrimary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );
      final int pendingCountPrimary = countItems<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received ($primary)',
          amount: formatAmount(receivedPrimary, primary),
          // changePercent: '5.2',
          isPositive: true,
          icon: Icons.payments,
          currency: primary,
        ),
      );

      cards.add(
        KpiCardSpec(
          title: 'Pending ($primary)',
          amount: formatAmount(pendingPrimary, primary),
          subtitle: pendingCountPrimary > 0
              ? '$pendingCountPrimary pending'
              : null,
          // changePercent: '1.2',
          isPositive: true,
          icon: Icons.pending_actions,
          currency: primary,
        ),
      );

      // Secondary Currency Received & Pending
      final double receivedSecondary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: secondary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: true,
      );
      final double pendingSecondary = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: secondary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );
      final int pendingCountSecondary = countItems<IncomeItem>(
        items: incomeItems,
        currency: secondary,
        getCurrency: (final IncomeItem item) => item.currency,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received ($secondary)',
          amount: formatAmount(receivedSecondary, secondary),
          // changePercent: '3.8',
          isPositive: true,
          icon: Icons.account_balance_wallet,
          currency: secondary,
        ),
      );

      cards.add(
        KpiCardSpec(
          title: 'Pending ($secondary)',
          amount: formatAmount(pendingSecondary, secondary),
          subtitle: pendingCountSecondary > 0
              ? '$pendingCountSecondary pending'
              : null,
          // changePercent: '0.8',
          isPositive: true,
          icon: Icons.schedule,
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
      final double pending = calculateTotal<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getAmount: (final IncomeItem item) => item.amount,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );
      final int pendingCount = countItems<IncomeItem>(
        items: incomeItems,
        currency: primary,
        getCurrency: (final IncomeItem item) => item.currency,
        getStatus: (final IncomeItem item) => item.status,
        requiredStatus: false,
      );

      cards.add(
        KpiCardSpec(
          title: 'Total Received',
          amount: formatAmount(received, primary),
          // changePercent: '5.2',
          isPositive: true,
          icon: Icons.payments,
          currency: primary,
        ),
      );

      cards.add(
        KpiCardSpec(
          title: 'Pending',
          amount: formatAmount(pending, primary),
          subtitle: pendingCount > 0 ? '$pendingCount pending' : null,
          // changePercent: '1.2',
          isPositive: true,
          icon: Icons.pending_actions,
          currency: primary,
        ),
      );
    }

    return cards;
  }
}
