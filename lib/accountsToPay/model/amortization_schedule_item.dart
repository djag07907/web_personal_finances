class AmortizationScheduleItem {
  final int quotaNumber;
  final DateTime dueDate;
  final double quotaAmount;
  final double principal;
  final double interest;
  final double remainingBalance;
  final bool isPaid;
  final DateTime? paidDate;

  const AmortizationScheduleItem({
    required this.quotaNumber,
    required this.dueDate,
    required this.quotaAmount,
    required this.principal,
    required this.interest,
    required this.remainingBalance,
    this.isPaid = false,
    this.paidDate,
  });
}
