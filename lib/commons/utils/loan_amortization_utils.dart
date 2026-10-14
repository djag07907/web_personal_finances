import 'dart:math' as math;
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';

class LoanAmortizationUtils {
  /// Calculates the standard fixed monthly payment (French Amortization System)
  /// given principal, annual interest rate percentage, and total duration in months.
  static double calculateMonthlyQuota({
    required final double principal,
    required final double annualInterestRatePercent,
    required final int totalMonths,
  }) {
    if (principal <= 0 || totalMonths <= 0) {
      return 0.0;
    }
    if (annualInterestRatePercent <= 0) {
      return principal / totalMonths;
    }

    // Monthly interest rate in decimal
    final double monthlyRate = (annualInterestRatePercent / 100.0) / 12.0;

    // French formula: A = P * [i * (1 + i)^n] / [(1 + i)^n - 1]
    final double factor = math.pow(1.0 + monthlyRate, totalMonths).toDouble();
    final double quota = principal * (monthlyRate * factor) / (factor - 1.0);
    return quota;
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
        : calculateMonthlyQuota(
            principal: principal,
            annualInterestRatePercent: annualRate,
            totalMonths: totalQuotas,
          );

    final double monthlyRate = (annualRate / 100.0) / 12.0;
    double currentBalance = principal;
    final double totalPaid = item.totalPaid;
    double runningPaidConsumed = totalPaid;

    final List<AmortizationScheduleItem> schedule =
        <AmortizationScheduleItem>[];

    for (int k = 1; k <= totalQuotas; k++) {
      final double interest = monthlyRate > 0
          ? currentBalance * monthlyRate
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

      final DateTime dueDate = addMonths(item.dueDate, k - 1);

      // Determine if this quota has been covered by payments
      bool isPaid = false;
      if (item.isFullyPaid) {
        isPaid = true;
      } else if (runningPaidConsumed >= actualQuota) {
        isPaid = true;
        runningPaidConsumed -= actualQuota;
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
