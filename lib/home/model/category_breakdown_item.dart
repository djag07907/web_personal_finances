import 'dart:ui';

class CategoryBreakdownItem {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryBreakdownItem({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
