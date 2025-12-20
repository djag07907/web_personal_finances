import 'package:flutter/material.dart';

class TransactionItem {
  final String title;
  final String category;
  final String date;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;

  const TransactionItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
  });
}
