class SavingItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final double goalAmount;
  final bool status;

  SavingItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.goalAmount,
    required this.status,
  });
}
