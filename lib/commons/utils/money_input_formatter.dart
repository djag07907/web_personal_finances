import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    final RegExp regex = RegExp(r'^[0-9.,]*$');

    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
