class AccountReceivableItem {
  final String id;
  final String debtorName;
  final String description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? receivedDate;
  final bool isReceived;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  AccountReceivableItem({
    required this.id,
    required this.debtorName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.receivedDate,
    this.isReceived = false,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  factory AccountReceivableItem.fromMap(final Map<String, dynamic> map) {
    return AccountReceivableItem(
      id: map['id'],
      debtorName: map['debtorName'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      dueDate: DateTime.parse(map['dueDate']),
      receivedDate: map['receivedDate'] != null
          ? DateTime.parse(map['receivedDate'])
          : null,
      isReceived: map['isReceived'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      tags: List<String>.from(map['tags'] ?? const <String>[]),
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'debtorName': debtorName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'isReceived': isReceived,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
