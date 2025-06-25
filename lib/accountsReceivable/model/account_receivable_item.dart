class AccountReceivableItem {
  final String id;
  final String debtorName;
  final String description;
  final double amount;
  final DateTime dueDate;
  final DateTime? receivedDate;
  final bool isReceived;

  AccountReceivableItem({
    required this.id,
    required this.debtorName,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.receivedDate,
    this.isReceived = false,
  });
}
