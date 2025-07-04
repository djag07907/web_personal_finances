import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class DatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(String) onDateSelected;

  const DatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
  }

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      content: Container(
        width: 500,
        height: 650,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 80,
              color: LightColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Row(
                children: <Widget>[
                  RawMaterialButton(
                    elevation: 0,
                    fillColor: white,
                    onPressed: _previousMonth,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: LightColors.primary,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _formatTitleDate(),
                        style: const TextStyle(
                          color: white,
                          fontSize: fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    elevation: 0,
                    fillColor: white,
                    onPressed: _nextMonth,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: LightColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Row(
                children: <Widget>[
                  RawMaterialButton(
                    elevation: 0,
                    fillColor: greyHard,
                    onPressed: _previousYear,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: white,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_focusedDate.year}',
                        style: const TextStyle(
                          color: greyHard,
                          fontSize: fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    elevation: 0,
                    fillColor: greyHard,
                    onPressed: _nextYear,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 7,
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  ..._buildDaysOfWeek(),
                  ..._buildCalendarDays(),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        SizedBox(
          width: 150,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              foregroundColor: LightColors.primary,
              backgroundColor: white,
              side: const BorderSide(
                color: LightColors.primary,
              ),
            ),
            child: Text(
              context.translate('cancel'),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              foregroundColor: white,
              backgroundColor: LightColors.primary,
            ),
            child: Text(
              context.translate('select'),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onDaySelected(
    final DateTime day,
  ) {
    setState(() => _focusedDate = day);
  }

  void _previousYear() {
    setState(() {
      _focusedDate =
          DateTime(_focusedDate.year - 1, _focusedDate.month, _focusedDate.day);
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDate =
          DateTime(_focusedDate.year, _focusedDate.month - 1, _focusedDate.day);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate =
          DateTime(_focusedDate.year, _focusedDate.month + 1, _focusedDate.day);
    });
  }

  void _nextYear() {
    setState(() {
      _focusedDate =
          DateTime(_focusedDate.year + 1, _focusedDate.month, _focusedDate.day);
    });
  }

  void _selectDate() {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(_focusedDate);
    widget.onDateSelected(formattedDate);
  }

  String _formatTitleDate() {
    final Locale localeOf = Localizations.localeOf(context);
    return DateFormat('dd, MMMM', localeOf.languageCode).format(_focusedDate);
  }

  List<Widget> _buildDaysOfWeek() {
    final List<Widget> dayNamesList = <Widget>[];

    final List<String> weekDayShortNames =
        Localizations.localeOf(context).languageCode == esLanguage
            ? weekDayShortNamesES
            : weekDayShortNamesEN;

    for (String day in weekDayShortNames) {
      dayNamesList.add(
        Center(
          child: Text(
            context.translate(day),
            style: TextStyle(
              color: day == sundayShortEn ||
                      day == saturdayShortEn ||
                      day == sundayShortEs ||
                      day == saturdayShortEs
                  ? greyHard
                  : LightColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return dayNamesList;
  }

  List<Widget> _buildCalendarDays() {
    final List<Widget> days = <Widget>[];

    final DateTime firstDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      1,
    );

    final DateTime lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );

    for (int paddingDay = 0;
        paddingDay < firstDayOfMonth.weekday;
        paddingDay++) {
      days.add(Container());
    }

    for (int calendarDay = 1;
        calendarDay <= lastDayOfMonth.day;
        calendarDay++) {
      final DateTime date = DateTime(
        _focusedDate.year,
        _focusedDate.month,
        calendarDay,
      );
      days.add(
        GestureDetector(
          onTap: () => _onDaySelected(date),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: transparent,
                  border: Border.all(
                    color: _focusedDate.day == calendarDay &&
                            _focusedDate.month == _focusedDate.month
                        ? LightColors.primary
                        : transparent,
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$calendarDay',
                  style: TextStyle(
                    color: _focusedDate.day == calendarDay &&
                            _focusedDate.month == _focusedDate.month
                        ? LightColors.primary
                        : (date.weekday == DateTime.sunday ||
                                date.weekday == DateTime.saturday)
                            ? greyHard
                            : greyHard,
                    fontWeight: _focusedDate.day == calendarDay &&
                            _focusedDate.month == _focusedDate.month
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return days;
  }
}
