class FinancialData {
  final double totalExpensesLempiras;
  final double totalExpensesDollars;
  final double totalIncomesLempiras;
  final double totalIncomesDollars;

  FinancialData({
    required this.totalExpensesLempiras,
    required this.totalExpensesDollars,
    required this.totalIncomesLempiras,
    required this.totalIncomesDollars,
  });

  double get totalExpenses =>
      totalExpensesLempiras + (totalExpensesDollars * getDollarValue());
  double get totalIncomes =>
      totalIncomesLempiras + (totalIncomesDollars * getDollarValue());
  double get spendingCapacity => totalIncomes - totalExpenses;
  // Placeholder for getting current dollar value
  double getDollarValue() {
    // You can fetch the dollar value dynamically or set it statically for now
    return 25.0; // Example: 1 USD = 24 HNL
  }
}
