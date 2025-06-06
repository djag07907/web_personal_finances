import 'package:flutter/material.dart';

class ExpenseToIncomeBar extends StatelessWidget {
  final double totalIncomes;
  final double totalExpenses;

  const ExpenseToIncomeBar({
    super.key,
    required this.totalIncomes,
    required this.totalExpenses,
  });

  @override
  Widget build(final BuildContext context) {
    final double percentage =
        (totalIncomes > 0) ? (totalExpenses / totalIncomes) * 100 : 0.0;
    Color barColor;
    String feedbackText;

    if (percentage < 20) {
      barColor = Colors.green; // Healthy
      feedbackText =
          'Your expenses are ${percentage.toStringAsFixed(1)}% of your income. Well done!';
    } else if (percentage < 40) {
      barColor = Colors.orange; // Caution
      feedbackText =
          'Your expenses are ${percentage.toStringAsFixed(1)}% of your income. Keep an eye on your spending!';
    } else {
      barColor = Colors.red; // Unhealthy
      feedbackText =
          'Your expenses are ${percentage.toStringAsFixed(1)}% of your income. Consider reducing your expenses!';
    }
    return Column(
      spacing: 10.0,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 500,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: barColor,
              ),
            ),
          ),
        ),
        Text(
          feedbackText,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
