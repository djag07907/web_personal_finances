import 'package:web_personal_finances/commons/enum/custom_expense_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/resources/constants.dart';

class ExpenseItem {
  final String id;
  final String userId;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final String dateDue;
  final bool status;
  final bool isPaid;
  final bool isFixed;
  final CustomExpenseCategoryOptions category;
  final CustomFrequencyOptions frequency;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  ExpenseItem({
    required this.id,
    this.userId = emptyString,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateDue,
    required this.status,
    this.isPaid = true,
    this.isFixed = true,
    this.category = CustomExpenseCategoryOptions.housing,
    this.frequency = CustomFrequencyOptions.monthly,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  factory ExpenseItem.fromMap(final Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'] ?? emptyString,
      userId: map['userId'] ?? emptyString,
      name: map['name'] ?? emptyString,
      comment: map['comment'] ?? emptyString,
      currency: map['currency'] ?? usdCurrency,
      amount: (map['amount'] ?? 0).toDouble(),
      dateDue: map['dateDue'] ?? emptyString,
      status: map['status'] ?? false,
      isPaid: map['isPaid'] ?? true,
      isFixed: map['isFixed'] ?? true,
      category: CustomExpenseCategoryOptions.values.firstWhere(
        (final CustomExpenseCategoryOptions element) =>
            element.name == map['category'],
        orElse: () => CustomExpenseCategoryOptions.housing,
      ),
      frequency: CustomFrequencyOptions.values.firstWhere(
        (final CustomFrequencyOptions element) =>
            element.name == map['frequency'],
        orElse: () => CustomFrequencyOptions.monthly,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : const <String>[],
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'dateDue': dateDue,
      'status': status,
      'isPaid': isPaid,
      'isFixed': isFixed,
      'category': category.name,
      'frequency': frequency.name,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
