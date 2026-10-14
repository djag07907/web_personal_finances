import 'package:web_personal_finances/resources/constants.dart';

class AccountToPayPayment {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;

  AccountToPayPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
  });

  factory AccountToPayPayment.fromMap(final Map<String, dynamic> map) {
    return AccountToPayPayment(
      id: map['id'] ?? emptyString,
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate:
          DateTime.tryParse(map['paymentDate'] ?? emptyString) ??
          DateTime.now(),
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}
