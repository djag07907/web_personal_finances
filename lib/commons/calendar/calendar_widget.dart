import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/calendar/date_picker.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class CustomCalendarDialog {
  Future<DateTime?> showDateDialog({
    required final BuildContext context,
    required final TextEditingController dateController,
  }) {
    return showDialog(
      context: context,
      builder: (
        final BuildContext context,
      ) {
        return Dialog(
          backgroundColor: transparent,
          child: DatePicker(
            initialDate: dateController.text.isNotEmpty
                ? DateFormat(dayMonthYearFormat).parse(dateController.text)
                : DateTime.now(),
            onDateSelected: (final String formattedDate) {
              dateController.text = formattedDate;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
