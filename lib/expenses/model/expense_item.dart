class ExpenseItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final String dateDue;
  final bool status;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateDue,
    required this.status,
  });
}
