import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/resources/constants.dart';

class IncomeItem {
  final String id;
  final String userId;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final String dateToReceive;
  final bool status;
  final DateTime? createdDate;
  final CustomFrequencyOptions frequency;
  final List<String> tags;

  IncomeItem({
    required this.id,
    this.userId = emptyString,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateToReceive,
    required this.status,
    this.createdDate,
    required this.frequency,
    this.tags = const <String>[],
  });

  factory IncomeItem.fromMap(final Map<String, dynamic> map) {
    return IncomeItem(
      id: map['id'] ?? emptyString,
      userId: map['userId'] ?? emptyString,
      name: map['name'] ?? emptyString,
      comment: map['comment'] ?? emptyString,
      currency: map['currency'] ?? usdCurrency,
      amount: (map['amount'] ?? 0).toDouble(),
      dateToReceive: map['dateToReceive'] ?? emptyString,
      status: map['status'] ?? false,
      frequency: CustomFrequencyOptions.values.firstWhere(
        (final CustomFrequencyOptions element) =>
            element.name == map['frequency'],
        orElse: () => CustomFrequencyOptions.once,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : const <String>[],
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
      'dateToReceive': dateToReceive,
      'status': status,
      'createdDate': createdDate?.toIso8601String(),
      'frequency': frequency.name,
      'tags': tags,
    };
  }
}
