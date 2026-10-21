import 'dart:math' as math;
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_interest_type.dart';

class LoanAmortizationUtils {
  /// Returns the standard number of payment periods per year for the given [frequency].
  static int getPeriodsPerYear(final CustomFrequencyOptions frequency) {
    switch (frequency) {
      case CustomFrequencyOptions.daily:
        return 365;
      case CustomFrequencyOptions.weekly:
        return 52;
      case CustomFrequencyOptions.biweekly:
        return 26;
      case CustomFrequencyOptions.monthly:
      case CustomFrequencyOptions.once:
        return 12;
      case CustomFrequencyOptions.yearly:
        return 1;
    }
  }

  /// Calculates the periodic quota payment given principal, annual interest rate percentage,
  /// total quotas, payment frequency, and interest calculation type (flat vs French).
  static double calculatePeriodicQuota({
    required final double principal,
    required final double annualInterestRatePercent,
    required final int totalQuotas,
    final CustomFrequencyOptions frequency = CustomFrequencyOptions.monthly,
    final CustomInterestType interestType = CustomInterestType.flat,
  }) {
    if (principal <= 0 || totalQuotas <= 0) {
      return 0.0;
    }
    if (annualInterestRatePercent <= 0) {
      return principal / totalQuotas;
    }

    final int periodsPerYear = getPeriodsPerYear(frequency);

    if (interestType == CustomInterestType.flat) {
      // Flat (Simple) Interest: Total interest is calculated on the initial principal
      final double years = totalQuotas / periodsPerYear;
      final double totalInterest =
          principal * (annualInterestRatePercent / 100.0) * years;
      return (principal + totalInterest) / totalQuotas;
    }

    // French Amortization System (declining balance / saldo insoluto)
    final double periodicRate =
        (annualInterestRatePercent / 100.0) / periodsPerYear;
    final double factor = math.pow(1.0 + periodicRate, totalQuotas).toDouble();
    if (factor - 1.0 == 0) {
      return principal / totalQuotas;
    }
    final double quota = principal * (periodicRate * factor) / (factor - 1.0);
    return quota;
  }

  /// Calculates the standard monthly payment given principal, annual interest rate percentage,
  /// total duration in months, and interest calculation type.
  static double calculateMonthlyQuota({
    required final double principal,
    required final double annualInterestRatePercent,
    required final int totalMonths,
    final CustomInterestType interestType = CustomInterestType.flat,
  }) {
    return calculatePeriodicQuota(
      principal: principal,
      annualInterestRatePercent: annualInterestRatePercent,
      totalQuotas: totalMonths,
      frequency: CustomFrequencyOptions.monthly,
      interestType: interestType,
    );
  }

  /// Calculates the due date for the [periodIndex]-th period (0-indexed: 0 is the start date)
  /// based on the given [frequency].
  static DateTime calculateDueDateForPeriod({
    required final DateTime startDate,
    required final int periodIndex,
    required final CustomFrequencyOptions frequency,
  }) {
    if (periodIndex <= 0) {
      return startDate;
    }
    switch (frequency) {
      case CustomFrequencyOptions.daily:
        return startDate.add(Duration(days: periodIndex));
      case CustomFrequencyOptions.weekly:
        return startDate.add(Duration(days: 7 * periodIndex));
      case CustomFrequencyOptions.biweekly:
        return startDate.add(Duration(days: 14 * periodIndex));
      case CustomFrequencyOptions.monthly:
      case CustomFrequencyOptions.once:
        return addMonths(startDate, periodIndex);
      case CustomFrequencyOptions.yearly:
        return addYears(startDate, periodIndex);
    }
  }

  /// Safely adds [yearsToAdd] years to a [date], handling leap year clamping (e.g., Feb 29).
  static DateTime addYears(final DateTime date, final int yearsToAdd) {
    if (yearsToAdd == 0) {
      return date;
    }
    final int newYear = date.year + yearsToAdd;
    final int daysInTargetMonth = DateTime(newYear, date.month + 1, 0).day;
    final int newDay = math.min(date.day, daysInTargetMonth);
    return DateTime(
      newYear,
      date.month,
      newDay,
      date.hour,
      date.minute,
      date.second,
    );
  }

  /// Generates schedule for generic terms.
  static List<AmortizationScheduleItem> generateScheduleForTerms({
    required final double principal,
    required final double annualRate,
    required final int totalQuotas,
    required final CustomFrequencyOptions frequency,
    final double? monthlyQuota,
    required final double totalPaid,
    required final bool isFullyPaid,
    required final DateTime startDate,
    final CustomInterestType interestType = CustomInterestType.flat,
  }) {
    if (totalQuotas <= 0 || principal <= 0) {
      return const <AmortizationScheduleItem>[];
    }

    final double quotaAmount = monthlyQuota != null && monthlyQuota > 0
        ? monthlyQuota
        : calculatePeriodicQuota(
            principal: principal,
            annualInterestRatePercent: annualRate,
            totalQuotas: totalQuotas,
            frequency: frequency,
            interestType: interestType,
          );

    final int periodsPerYear = getPeriodsPerYear(frequency);
    double runningPaidConsumed = totalPaid;
    final List<AmortizationScheduleItem> schedule =
        <AmortizationScheduleItem>[];

    if (interestType == CustomInterestType.flat) {
      // Flat Rate: interest is uniform across periods
      final double years = totalQuotas / periodsPerYear;
      final double totalFlatInterest = annualRate > 0
          ? principal * (annualRate / 100.0) * years
          : 0.0;
      final double periodicInterest = totalQuotas > 0
          ? totalFlatInterest / totalQuotas
          : 0.0;
      final double periodicPrincipal = totalQuotas > 0
          ? principal / totalQuotas
          : 0.0;

      double remainingPrincipal = principal;

      for (int k = 1; k <= totalQuotas; k++) {
        double principalPayment = periodicPrincipal;
        double interest = periodicInterest;
        double actualQuota = quotaAmount;

        if (k == totalQuotas) {
          principalPayment = remainingPrincipal;
          actualQuota = principalPayment + interest;
          remainingPrincipal = 0.0;
        } else {
          remainingPrincipal = math.max(
            0.0,
            remainingPrincipal - principalPayment,
          );
        }

        final DateTime dueDate = calculateDueDateForPeriod(
          startDate: startDate,
          periodIndex: k - 1,
          frequency: frequency,
        );

        bool isPaid = false;
        if (isFullyPaid) {
          isPaid = true;
        } else if (runningPaidConsumed >= (actualQuota - 0.05)) {
          isPaid = true;
          runningPaidConsumed = math.max(
            0.0,
            runningPaidConsumed - actualQuota,
          );
        }

        schedule.add(
          AmortizationScheduleItem(
            quotaNumber: k,
            dueDate: dueDate,
            quotaAmount: actualQuota,
            principal: principalPayment,
            interest: interest,
            remainingBalance: remainingPrincipal,
            isPaid: isPaid,
          ),
        );
      }

      return schedule;
    }

    // French Amortization System (declining balance)
    final double periodicRate = (annualRate / 100.0) / periodsPerYear;
    double currentBalance = principal;

    for (int k = 1; k <= totalQuotas; k++) {
      final double interest = periodicRate > 0
          ? currentBalance * periodicRate
          : 0.0;
      double principalPayment = quotaAmount - interest;
      double actualQuota = quotaAmount;

      if (k == totalQuotas || currentBalance - principalPayment < 0.001) {
        principalPayment = currentBalance;
        actualQuota = principalPayment + interest;
        currentBalance = 0.0;
      } else {
        currentBalance -= principalPayment;
      }

      final DateTime dueDate = calculateDueDateForPeriod(
        startDate: startDate,
        periodIndex: k - 1,
        frequency: frequency,
      );

      bool isPaid = false;
      if (isFullyPaid) {
        isPaid = true;
      } else if (runningPaidConsumed >= (actualQuota - 0.05)) {
        isPaid = true;
        runningPaidConsumed = math.max(0.0, runningPaidConsumed - actualQuota);
      }

      schedule.add(
        AmortizationScheduleItem(
          quotaNumber: k,
          dueDate: dueDate,
          quotaAmount: actualQuota,
          principal: principalPayment,
          interest: interest,
          remainingBalance: currentBalance < 0 ? 0.0 : currentBalance,
          isPaid: isPaid,
        ),
      );

      if (currentBalance <= 0) {
        break;
      }
    }

    return schedule;
  }

  /// Generates the complete amortization schedule for a loan item.
  static List<AmortizationScheduleItem> generateSchedule(
    final AccountToPayItem item,
  ) {
    return generateScheduleForTerms(
      principal: item.amount,
      annualRate: item.interestRate ?? 0.0,
      totalQuotas: item.totalQuotas ?? 0,
      frequency: item.frequency,
      monthlyQuota: item.monthlyQuota,
      totalPaid: item.totalPaid,
      isFullyPaid: item.isFullyPaid,
      startDate: item.dueDate,
      interestType: item.interestType,
    );
  }

  /// Generates the complete amortization schedule for a receivable financing/loan item.
  static List<AmortizationScheduleItem> generateReceivableSchedule(
    final AccountReceivableItem item,
  ) {
    return generateScheduleForTerms(
      principal: item.amount,
      annualRate: item.interestRate ?? 0.0,
      totalQuotas: item.totalQuotas ?? 0,
      frequency: item.frequency,
      monthlyQuota: item.monthlyQuota,
      totalPaid: item.totalCollected,
      isFullyPaid: item.isFullyPaid,
      startDate: item.dueDate,
      interestType: item.interestType,
    );
  }

  /// Calculates total interest that will be paid across all scheduled quotas.
  static double calculateTotalInterest(
    final List<AmortizationScheduleItem> schedule,
  ) {
    return schedule.fold(
      0.0,
      (final double sum, final AmortizationScheduleItem item) =>
          sum + item.interest,
    );
  }

  /// Finds the next upcoming unpaid quota in the schedule.
  static AmortizationScheduleItem? getNextDueQuota(
    final List<AmortizationScheduleItem> schedule,
  ) {
    for (final AmortizationScheduleItem item in schedule) {
      if (!item.isPaid) {
        return item;
      }
    }
    return null;
  }

  /// Safely adds [monthsToAdd] months to a [date], preserving the day when possible
  /// or clamping to the final day of the target month.
  static DateTime addMonths(final DateTime date, final int monthsToAdd) {
    if (monthsToAdd == 0) {
      return date;
    }
    final int newYear = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
    final int newMonth = ((date.month - 1 + monthsToAdd) % 12) + 1;
    final int daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day;
    final int newDay = math.min(date.day, daysInTargetMonth);

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
    );
  }

  /// Returns the number of paid quotas for a loan account item.
  static int getPaidQuotasCount(final AccountToPayItem item) {
    final int total = item.totalQuotas ?? 0;
    if (total <= 0) {
      return 0;
    }
    if (item.isFullyPaid) {
      return total;
    }
    final List<AmortizationScheduleItem> schedule = generateSchedule(item);
    return schedule
        .where((final AmortizationScheduleItem q) => q.isPaid)
        .length;
  }

  /// Returns the number of paid/collected quotas for a receivable loan/financing item.
  static int getPaidReceivableQuotasCount(final AccountReceivableItem item) {
    final int total = item.totalQuotas ?? 0;
    if (total <= 0) {
      return 0;
    }
    if (item.isFullyPaid) {
      return total;
    }
    final List<AmortizationScheduleItem> schedule = generateReceivableSchedule(
      item,
    );
    return schedule
        .where((final AmortizationScheduleItem q) => q.isPaid)
        .length;
  }
}
