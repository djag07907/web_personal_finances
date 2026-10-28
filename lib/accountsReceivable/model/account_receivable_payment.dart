import 'package:web_personal_finances/resources/constants.dart';

class AccountReceivablePayment {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;

  AccountReceivablePayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
  });

  factory AccountReceivablePayment.fromMap(final Map<String, dynamic> map) {
    return AccountReceivablePayment(
      id: map['id'] ?? emptyString,
      amount: map['amount'] is num
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? emptyString) ?? 0.0,
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
