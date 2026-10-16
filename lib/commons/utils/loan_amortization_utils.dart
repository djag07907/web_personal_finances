import 'dart:math' as math;
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';

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

  /// Calculates the standard fixed periodic quota payment (French Amortization System)
  /// given principal, annual interest rate percentage, total quotas, and payment frequency.
  static double calculatePeriodicQuota({
    required final double principal,
    required final double annualInterestRatePercent,
    required final int totalQuotas,
    final CustomFrequencyOptions frequency = CustomFrequencyOptions.monthly,
  }) {
    if (principal <= 0 || totalQuotas <= 0) {
      return 0.0;
    }
    if (annualInterestRatePercent <= 0) {
      return principal / totalQuotas;
    }

    final int periodsPerYear = getPeriodsPerYear(frequency);
    final double periodicRate =
        (annualInterestRatePercent / 100.0) / periodsPerYear;

    // French formula: A = P * [i * (1 + i)^n] / [(1 + i)^n - 1]
    final double factor = math.pow(1.0 + periodicRate, totalQuotas).toDouble();
    if (factor - 1.0 == 0) {
      return principal / totalQuotas;
    }
    final double quota = principal * (periodicRate * factor) / (factor - 1.0);
    return quota;
  }

  /// Calculates the standard fixed monthly payment (French Amortization System)
  /// given principal, annual interest rate percentage, and total duration in months.
  static double calculateMonthlyQuota({
    required final double principal,
    required final double annualInterestRatePercent,
    required final int totalMonths,
  }) {
    return calculatePeriodicQuota(
      principal: principal,
      annualInterestRatePercent: annualInterestRatePercent,
      totalQuotas: totalMonths,
      frequency: CustomFrequencyOptions.monthly,
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

  /// Generates the complete amortization schedule for a loan item.
  static List<AmortizationScheduleItem> generateSchedule(
    final AccountToPayItem item,
  ) {
    final int totalQuotas = item.totalQuotas ?? 0;
    final double principal = item.amount;
    final double annualRate = item.interestRate ?? 0.0;

    if (totalQuotas <= 0 || principal <= 0) {
      return const <AmortizationScheduleItem>[];
    }

    final double quotaAmount =
        item.monthlyQuota != null && item.monthlyQuota! > 0
        ? item.monthlyQuota!
        : calculatePeriodicQuota(
            principal: principal,
            annualInterestRatePercent: annualRate,
            totalQuotas: totalQuotas,
            frequency: item.frequency,
          );

    final int periodsPerYear = getPeriodsPerYear(item.frequency);
    final double periodicRate = (annualRate / 100.0) / periodsPerYear;
    double currentBalance = principal;
    final double totalPaid = item.totalPaid;
    double runningPaidConsumed = totalPaid;

    final List<AmortizationScheduleItem> schedule =
        <AmortizationScheduleItem>[];

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
        startDate: item.dueDate,
        periodIndex: k - 1,
        frequency: item.frequency,
      );

      // Determine if this quota has been covered by payments
      bool isPaid = false;
      if (item.isFullyPaid) {
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
        // Loan fully amortized before all quota slots
        break;
      }
    }

    return schedule;
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
}
