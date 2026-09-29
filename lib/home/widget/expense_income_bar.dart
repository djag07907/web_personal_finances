import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

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
    final double percentage = (totalIncomes > 0)
        ? (totalExpenses / totalIncomes) * 100
        : 0.0;
    Color barColor;
    String feedbackText;

    if (percentage < 20) {
      barColor = healthyGreen;
      final String raw = context.translate('expenses_low');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    } else if (percentage < 40) {
      barColor = cautionOrange;
      final String raw = context.translate('expenses_moderate');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    } else {
      barColor = unhealthyRed;
      final String raw = context.translate('expenses_high');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 500,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isDark ? DarkColors.surfaceLight : Colors.grey[300],
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
        const SizedBox(height: 10.0),
        Text(feedbackText, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
