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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? DarkColors.surface : white,
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      content: Container(
        width: 420,
        height: 520,
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              foregroundColor: LightColors.primary,
              backgroundColor: isDark ? DarkColors.surface : white,
              side: const BorderSide(color: LightColors.primary),
            ),
            child: Text(
              context.translate('cancel'),
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ),
        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: _selectDate,
            style: ElevatedButton.styleFrom(
              foregroundColor: white,
              backgroundColor: LightColors.primary,
            ),
            child: Text(
              context.translate('select'),
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(final BuildContext context) {
    final Locale localeOf = Localizations.localeOf(context);
    final List<String> monthNames = List<String>.generate(12, (
      final int index,
    ) {
      final DateTime dummyDate = DateTime(2024, index + 1, 1);
      return DateFormat('MMMM', localeOf.languageCode).format(dummyDate);
    });

    final int currentYear = DateTime.now().year;
    final int minYear = _focusedDate.year < (currentYear - 50)
        ? _focusedDate.year - 10
        : (currentYear - 50);
    final int maxYear = _focusedDate.year > (currentYear + 50)
        ? _focusedDate.year + 10
        : (currentYear + 50);
    final List<int> yearList = List<int>.generate(
      maxYear - minYear + 1,
      (final int index) => minYear + index,
    );

    return Container(
      color: LightColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left, color: white, size: 28),
            tooltip: 'Previous Month',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _focusedDate.month,
                  dropdownColor: LightColors.primary,
                  icon: const Icon(Icons.arrow_drop_down, color: white),
                  style: const TextStyle(
                    color: white,
                    fontSize: fontSize16,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (final int? newMonth) {
                    if (newMonth != null) {
                      setState(() {
                        final int maxDays = DateTime(
                          _focusedDate.year,
                          newMonth + 1,
                          0,
                        ).day;
                        final int newDay = _focusedDate.day > maxDays
                            ? maxDays
                            : _focusedDate.day;
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          newMonth,
                          newDay,
                        );
                      });
                    }
                  },
                  items: List<DropdownMenuItem<int>>.generate(12, (
                    final int i,
                  ) {
                    final int m = i + 1;
                    final String name = monthNames[i].isNotEmpty
                        ? monthNames[i][0].toUpperCase() +
                              monthNames[i].substring(1)
                        : emptyString;
                    return DropdownMenuItem<int>(
                      value: m,
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _focusedDate.year,
                  dropdownColor: LightColors.primary,
                  icon: const Icon(Icons.arrow_drop_down, color: white),
                  style: const TextStyle(
                    color: white,
                    fontSize: fontSize16,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (final int? newYear) {
                    if (newYear != null) {
                      setState(() {
                        final int maxDays = DateTime(
                          newYear,
                          _focusedDate.month + 1,
                          0,
                        ).day;
                        final int newDay = _focusedDate.day > maxDays
                            ? maxDays
                            : _focusedDate.day;
                        _focusedDate = DateTime(
                          newYear,
                          _focusedDate.month,
                          newDay,
                        );
                      });
                    }
                  },
                  items: yearList.map((final int y) {
                    return DropdownMenuItem<int>(
                      value: y,
                      child: Text(
                        '$y',
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: white, size: 28),
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  void _onDaySelected(final DateTime day) {
    setState(() => _focusedDate = day);
  }

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month - 1,
        _focusedDate.day,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + 1,
        _focusedDate.day,
      );
    });
  }

  void _selectDate() {
    final String formattedDate = DateFormat(
      dayMonthYearFormat,
    ).format(_focusedDate);
    widget.onDateSelected(formattedDate);
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
              color:
                  day == sundayShortEn ||
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

    for (
      int paddingDay = 0;
      paddingDay < firstDayOfMonth.weekday;
      paddingDay++
    ) {
      days.add(Container());
    }

    for (
      int calendarDay = 1;
      calendarDay <= lastDayOfMonth.day;
      calendarDay++
    ) {
      final DateTime date = DateTime(
        _focusedDate.year,
        _focusedDate.month,
        calendarDay,
      );
      final bool isSelected =
          _focusedDate.day == calendarDay &&
          _focusedDate.month == date.month &&
          _focusedDate.year == date.year;

      days.add(
        GestureDetector(
          onTap: () => _onDaySelected(date),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? LightColors.primary : transparent,
                  border: Border.all(
                    color: isSelected ? LightColors.primary : transparent,
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$calendarDay',
                  style: TextStyle(
                    color: isSelected
                        ? white
                        : (date.weekday == DateTime.sunday ||
                              date.weekday == DateTime.saturday)
                        ? greyHard
                        : greyHard,
                    fontWeight: isSelected
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
