import 'package:web_personal_finances/commons/enum/custom_account_to_pay_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AccountToPayItem {
  final String id;
  final String userId;
  final String creditorName;
  final String description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final bool isPaid;
  final bool status;
  final CustomAccountToPayCategoryOptions category;
  final CustomFrequencyOptions frequency;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  AccountToPayItem({
    required this.id,
    this.userId = emptyString,
    required this.creditorName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.paymentDate,
    this.isPaid = false,
    this.status = true,
    this.category = CustomAccountToPayCategoryOptions.other,
    this.frequency = CustomFrequencyOptions.once,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  AccountToPayItem copyWith({
    final bool? isPaid,
    final bool? status,
    final DateTime? paymentDate,
    final bool clearPaymentDate = false,
  }) {
    return AccountToPayItem(
      id: id,
      userId: userId,
      creditorName: creditorName,
      description: description,
      amount: amount,
      currency: currency,
      dueDate: dueDate,
      paymentDate: clearPaymentDate ? null : (paymentDate ?? this.paymentDate),
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      category: category,
      frequency: frequency,
      createdDate: createdDate,
      tags: tags,
      paymentMethod: paymentMethod,
    );
  }

  factory AccountToPayItem.fromMap(final Map<String, dynamic> map) {
    return AccountToPayItem(
      id: map['id'] ?? emptyString,
      userId: map['userId'] ?? emptyString,
      creditorName: map['creditorName'] ?? emptyString,
      description: map['description'] ?? emptyString,
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? usdCurrency,
      dueDate:
          DateTime.tryParse(map['dueDate'] ?? emptyString) ?? DateTime.now(),
      paymentDate: map['paymentDate'] != null
          ? DateTime.tryParse(map['paymentDate'])
          : null,
      isPaid: map['isPaid'] ?? false,
      status: map['status'] ?? true,
      category: CustomAccountToPayCategoryOptions.values.firstWhere(
        (final CustomAccountToPayCategoryOptions element) =>
            element.name == map['category'],
        orElse: () => CustomAccountToPayCategoryOptions.other,
      ),
      frequency: CustomFrequencyOptions.values.firstWhere(
        (final CustomFrequencyOptions element) =>
            element.name == map['frequency'],
        orElse: () => CustomFrequencyOptions.once,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate'])
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
      'creditorName': creditorName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'isPaid': isPaid,
      'status': status,
      'category': category.name,
      'frequency': frequency.name,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
