class IncomeItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final String dateToReceive;
  final bool status;

  IncomeItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateToReceive,
    required this.status,
  });
}
