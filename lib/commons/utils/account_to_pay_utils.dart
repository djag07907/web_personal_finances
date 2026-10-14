import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_payment.dart';
import 'package:web_personal_finances/commons/enum/custom_payment_filters.dart';

class AccountToPayUtils {
  /// Checks whether an account is past its due date and not yet fully settled.
  static bool isOverdue(final AccountToPayItem item, {final DateTime? now}) {
    if (item.isFullyPaid || !item.status) {
      return false;
    }
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime due = DateTime(
      item.dueDate.year,
      item.dueDate.month,
      item.dueDate.day,
    );
    return due.isBefore(today);
  }

  /// Evaluates the payment state: paid, overdue, partially paid, or pending.
  static CustomPaymentFilters getPaymentState(
    final AccountToPayItem item, {
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

  /// Records a new payment against the account, recalculating balances and status.
  static AccountToPayItem applyPayment({
    required final AccountToPayItem item,
    required final double amount,
    required final DateTime paymentDate,
    final String? paymentMethod,
    final String? notes,
  }) {
    final AccountToPayPayment payment = AccountToPayPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    final List<AccountToPayPayment> updatedPayments = <AccountToPayPayment>[
      ...item.payments,
      payment,
    ];
    final double totalPaid = updatedPayments.fold(
      0.0,
      (final double sum, final AccountToPayPayment p) => sum + p.amount,
    );
    final bool fullyPaid = totalPaid >= item.amount;
    return item.copyWith(
      payments: updatedPayments,
      isPaid: fullyPaid,
      paymentDate: fullyPaid ? paymentDate : item.paymentDate,
    );
  }

  /// Removes an individual payment from the ledger (e.g., undo or correction).
  static AccountToPayItem removePayment({
    required final AccountToPayItem item,
    required final String paymentId,
  }) {
    final List<AccountToPayPayment> updatedPayments = item.payments
        .where((final AccountToPayPayment p) => p.id != paymentId)
        .toList();
    final double totalPaid = updatedPayments.fold(
      0.0,
      (final double sum, final AccountToPayPayment p) => sum + p.amount,
    );
    final bool fullyPaid =
        updatedPayments.isNotEmpty && totalPaid >= item.amount;
    return item.copyWith(
      payments: updatedPayments,
      isPaid: fullyPaid,
      clearPaymentDate: !fullyPaid,
    );
  }
}
