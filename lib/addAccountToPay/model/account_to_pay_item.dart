class AccountToPayItem {
  final String id;
  final String creditorName;
  final String description;
  final double amount;
  final String currency;
  final String dueDate;
  final String? paymentDate;
  final bool isPaid;

  AccountToPayItem({
    required this.id,
    required this.creditorName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.paymentDate,
    this.isPaid = false,
  });
}
