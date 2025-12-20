class BillItem {
  final String title;
  final String provider;
  final String dueDate;
  final String dueMonth;
  final double amount;
  final bool isPastDue;

  const BillItem({
    required this.title,
    required this.provider,
    required this.dueDate,
    required this.dueMonth,
    required this.amount,
    this.isPastDue = false,
  });
}
