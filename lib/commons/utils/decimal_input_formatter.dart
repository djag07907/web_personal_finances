import 'package:flutter/services.dart';

/// Formatter that restricts text input to numbers with an optional decimal part
/// up to [decimalRange] places (default: 2).
class DecimalInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalInputFormatter({this.decimalRange = 2});

  @override
  TextEditingValue formatEditUpdate(
    final TextEditingValue oldValue,
    final TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final RegExp regex = RegExp('^\\d*\\.?\\d{0,$decimalRange}\$');
    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
