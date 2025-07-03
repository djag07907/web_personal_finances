class AccountToPayItem {
  final String id;
  final String creditorName;
  final String description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final bool isPaid;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  AccountToPayItem({
    required this.id,
    required this.creditorName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.paymentDate,
    this.isPaid = false,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  factory AccountToPayItem.fromMap(final Map<String, dynamic> map) {
    return AccountToPayItem(
      id: map['id'],
      creditorName: map['creditorName'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      dueDate: DateTime.parse(map['dueDate']),
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'])
          : null,
      isPaid: map['isPaid'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      tags: List<String>.from(map['tags'] ?? const <String>[]),
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditorName': creditorName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'isPaid': isPaid,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
