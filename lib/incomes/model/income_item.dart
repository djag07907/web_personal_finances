import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';

class IncomeItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final String dateToReceive;
  final bool status;
  final DateTime? createdDate;
  final CustomFrequencyOptions frequency;
  // final List<String> tags;
  // final String? paymentMethod;

  IncomeItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateToReceive,
    required this.status,
    this.createdDate,
    required this.frequency,
    // this.tags = const <String>[],
    // this.paymentMethod,
  });

  factory IncomeItem.fromMap(final Map<String, dynamic> map) {
    return IncomeItem(
      id: map['id'],
      name: map['name'],
      comment: map['comment'],
      currency: map['currency'],
      amount: map['amount'].toDouble(),
      dateToReceive: map['dateToReceive'],
      status: map['status'] ?? false,
      frequency: CustomFrequencyOptions.values.firstWhere(
        (final CustomFrequencyOptions element) =>
            element.name == map['frequency'],
        orElse: () => CustomFrequencyOptions.once,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
      // tags: List<String>.from(map['tags'] ?? const <String>[]),
      // paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'dateToReceive': dateToReceive,
      'status': status,
      'createdDate': createdDate?.toIso8601String(),
      'frequency': frequency.name,
      // 'tags': tags,
      // 'paymentMethod': paymentMethod,
    };
  }
}
