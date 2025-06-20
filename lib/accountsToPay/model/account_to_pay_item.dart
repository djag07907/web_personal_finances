class AccountPayableItem {
  final String id;
  final String creditorName;
  final String description;
  final double amount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final bool isPaid;

  AccountPayableItem({
    required this.id,
    required this.creditorName,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    this.isPaid = false,
  });
}
