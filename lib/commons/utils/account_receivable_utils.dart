import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_payment.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_payment_filters.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';

class AccountReceivableUtils {
  /// Resolves the next collection due date for a receivable.
  /// For loan/amortization items, this is the due date of the earliest unpaid quota.
  /// For recurring frequency items, this advances the start due date by the number of covered cycles.
  /// For settled or one-time items, it returns the base due date.
  static DateTime getNextDueDate(final AccountReceivableItem item) {
    if (item.frequency == CustomFrequencyOptions.once && item.isFullyPaid) {
      return item.dueDate;
    }

    if (item.isLoanAccount) {
      final List<AmortizationScheduleItem> schedule =
          LoanAmortizationUtils.generateReceivableSchedule(item);
      final AmortizationScheduleItem? nextQuota =
          LoanAmortizationUtils.getNextDueQuota(schedule);
      if (nextQuota != null) {
        return nextQuota.dueDate;
      }
      if (schedule.isNotEmpty) {
        return schedule.last.dueDate;
      }
    }

    if (item.frequency != CustomFrequencyOptions.once) {
      final double cycleAmount =
          (item.monthlyQuota != null && item.monthlyQuota! > 0)
          ? item.monthlyQuota!
          : item.amount;
      if (cycleAmount > 0) {
        final int periodsPaid = ((item.totalCollected + 0.05) / cycleAmount)
            .floor();
        if (periodsPaid > 0) {
          return LoanAmortizationUtils.calculateDueDateForPeriod(
            startDate: item.dueDate,
            periodIndex: periodsPaid,
            frequency: item.frequency,
          );
        }
      }
    }

    return item.dueDate;
  }

  /// Checks whether an account receivable is past its next due date and not yet fully settled.
  static bool isOverdue(
    final AccountReceivableItem item, {
    final DateTime? now,
  }) {
    if (item.isFullyPaid || !item.status) {
      return false;
    }
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime nextDue = getNextDueDate(item);
    final DateTime due = DateTime(nextDue.year, nextDue.month, nextDue.day);
    return due.isBefore(today);
  }

  /// Number of days until next due date relative to [now].
  /// Returns 0 if due today, positive if due in the future, negative if past due.
  static int daysUntilDue(
    final AccountReceivableItem item, {
    final DateTime? now,
  }) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime nextDue = getNextDueDate(item);
    final DateTime due = DateTime(nextDue.year, nextDue.month, nextDue.day);
    return due.difference(today).inDays;
  }

  /// Checks whether an unpaid active account is due soon (within [days] days, inclusive of today).
  static bool isDueSoon(
    final AccountReceivableItem item, {
    final DateTime? now,
    final int days = 3,
  }) {
    if (item.isFullyPaid || !item.status) {
      return false;
    }
    final int diff = daysUntilDue(item, now: now);
    return diff >= 0 && diff <= days;
  }

  /// Evaluates the payment/collection state: paid, overdue, partially paid, or pending.
  static CustomPaymentFilters getPaymentState(
    final AccountReceivableItem item, {
    final DateTime? now,
  }) {
    if (item.isFullyPaid) {
      return CustomPaymentFilters.paid;
    }
    if (isOverdue(item, now: now)) {
      return CustomPaymentFilters.overdue;
    }
    if (item.isPartiallyPaid) {
      return CustomPaymentFilters.partiallyPaid;
    }
    return CustomPaymentFilters.pending;
  }

  /// Records a new payment collection against the receivable, recalculating balances and status.
  static AccountReceivableItem applyPayment({
    required final AccountReceivableItem item,
    required final double amount,
    required final DateTime paymentDate,
    final String? paymentMethod,
    final String? notes,
  }) {
    final AccountReceivablePayment payment = AccountReceivablePayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    final List<AccountReceivablePayment> updatedPayments =
        <AccountReceivablePayment>[...item.payments, payment];
    final double totalPaid = updatedPayments.fold(
      0.0,
      (final double sum, final AccountReceivablePayment p) => sum + p.amount,
    );
    final bool fullyPaid = totalPaid >= item.amount;
    return item.copyWith(
      payments: updatedPayments,
      isReceived: fullyPaid,
      paymentDate: fullyPaid ? paymentDate : item.paymentDate,
    );
  }

  /// Removes an individual payment from the ledger (e.g., undo or correction).
  static AccountReceivableItem removePayment({
    required final AccountReceivableItem item,
    required final String paymentId,
  }) {
    final List<AccountReceivablePayment> updatedPayments = item.payments
        .where((final AccountReceivablePayment p) => p.id != paymentId)
        .toList();
    final double totalPaid = updatedPayments.fold(
      0.0,
      (final double sum, final AccountReceivablePayment p) => sum + p.amount,
    );
    final bool fullyPaid =
        updatedPayments.isNotEmpty && totalPaid >= item.amount;
    return item.copyWith(
      payments: updatedPayments,
      isReceived: fullyPaid,
      clearPaymentDate: !fullyPaid,
    );
  }
}
