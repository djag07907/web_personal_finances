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
  double getDollarValue() {
    return 25.0;
  }
}
