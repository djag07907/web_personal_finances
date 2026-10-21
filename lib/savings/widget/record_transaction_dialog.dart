import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';

class RecordTransactionDialog extends StatefulWidget {
  final SavingItem item;
  final CustomSavingTransactionType initialType;
  final void Function(SavingItem updatedItem, SavingRegistryItem transaction)
  onTransactionRecorded;

  const RecordTransactionDialog({
    super.key,
    required this.item,
    this.initialType = CustomSavingTransactionType.deposit,
    required this.onTransactionRecorded,
  });

  static Future<void> show({
    required final BuildContext context,
    required final SavingItem item,
    final CustomSavingTransactionType initialType =
        CustomSavingTransactionType.deposit,
    required final void Function(
      SavingItem updatedItem,
      SavingRegistryItem transaction,
    )
    onTransactionRecorded,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext ctx) {
        return Dialog(
          backgroundColor: transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: RecordTransactionDialog(
            item: item,
            initialType: initialType,
            onTransactionRecorded: onTransactionRecorded,
          ),
        );
      },
    );
  }

  @override
  State<RecordTransactionDialog> createState() =>
      _RecordTransactionDialogState();
}

class _RecordTransactionDialogState extends State<RecordTransactionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late CustomSavingTransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _dateController.text = DateFormat(dayMonthYearFormat).format(_selectedDate);
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _getEnteredAmount() {
    return double.tryParse(
          _amountController.text.replaceAll(',', emptyString),
        ) ??
        0.0;
  }

  double _getProjectedBalance() {
    final double entered = _getEnteredAmount();
    if (_selectedType == CustomSavingTransactionType.deposit) {
      return widget.item.currentAmount + entered;
    } else {
      final double result = widget.item.currentAmount - entered;
      return result < 0 ? 0.0 : result;
    }
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double enteredAmount = _getEnteredAmount();
    if (_selectedType == CustomSavingTransactionType.withdrawal &&
        enteredAmount > widget.item.currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('insufficient_savings_balance')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final SavingRegistryItem transaction = SavingRegistryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      savingId: widget.item.id,
      amount: enteredAmount,
      type: _selectedType,
      date: _selectedDate,
      createdDate: DateTime.now(),
      comment: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final List<SavingRegistryItem> updatedRegistries =
        List<SavingRegistryItem>.from(widget.item.registries)..add(transaction);

    final SavingItem updatedItem = widget.item.copyWith(
      registries: updatedRegistries,
      isGoalReached:
          _getProjectedBalance() >= widget.item.goalAmount &&
          widget.item.goalAmount > 0,
    );

    widget.onTransactionRecorded(updatedItem, transaction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? DarkColors.primary : LightColors.primary;
    final String currency = widget.item.currency;
    final double currentBalance = widget.item.currentAmount;
    final double projectedBalance = _getProjectedBalance();
    final double goal = widget.item.goalAmount;
    final double projectedPercent = goal > 0
        ? (projectedBalance / goal * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: _selectedType.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedType.icon,
                          color: _selectedType.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedType == CustomSavingTransactionType.deposit
                            ? context.translate('record_deposit')
                            : context.translate('record_withdrawal'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? white : LightColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? DarkColors.textSecondary : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.item.name} • ${context.translate('goal_amount')}: ${CurrencyKpiUtils.formatAmount(goal, currency)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Type Switcher
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = CustomSavingTransactionType.deposit;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color:
                                _selectedType ==
                                    CustomSavingTransactionType.deposit
                                ? Colors.green
                                : transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.translate('deposit'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  _selectedType ==
                                      CustomSavingTransactionType.deposit
                                  ? white
                                  : (isDark
                                        ? DarkColors.textSecondary
                                        : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType =
                                CustomSavingTransactionType.withdrawal;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color:
                                _selectedType ==
                                    CustomSavingTransactionType.withdrawal
                                ? Colors.redAccent
                                : transparent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            context.translate('withdrawal'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  _selectedType ==
                                      CustomSavingTransactionType.withdrawal
                                  ? white
                                  : (isDark
                                        ? DarkColors.textSecondary
                                        : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Balance summary card
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.translate('current_saved'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyKpiUtils.formatAmount(
                            currentBalance,
                            currency,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? white : LightColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          context.translate('new_balance'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyKpiUtils.formatAmount(
                            projectedBalance,
                            currency,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedType ==
                                    CustomSavingTransactionType.deposit
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                        Text(
                          '${projectedPercent.toStringAsFixed(1)}% ${context.translate('of_goal')}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Amount input
              CustomLabelInput(
                label: context.translate('amount'),
                hintText: context.translate('enter_amount'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <MoneyInputFormatter>[MoneyInputFormatter()],
                validator: (final String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.translate('please_enter_amount');
                  }
                  final double? parsed = double.tryParse(
                    value.replaceAll(',', emptyString),
                  );
                  if (parsed == null || parsed <= 0) {
                    return context.translate('please_enter_amount');
                  }
                  if (_selectedType == CustomSavingTransactionType.withdrawal &&
                      parsed > currentBalance) {
                    return context.translate('insufficient_savings_balance');
                  }
                  return null;
                },
                controller: _amountController,
              ),

              // Date input
              CustomLabelInput(
                label: context.translate('transaction_date'),
                hintText: context.translate('transaction_date'),
                isReadOnly: true,
                isCalendar: true,
                onTap: () async {
                  final CustomCalendarDialog calendar = CustomCalendarDialog();
                  final DateTime? selected = await calendar.showDateDialog(
                    context: context,
                    dateController: _dateController,
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedDate = selected;
                      _dateController.text = DateFormat(
                        dayMonthYearFormat,
                      ).format(selected);
                    });
                  }
                },
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('transaction_date');
                  }
                  return null;
                },
                controller: _dateController,
              ),

              // Comment / Notes input
              CustomLabelInput(
                label:
                    '${context.translate('comment')} (${context.translate('optional')})',
                hintText: context.translate('enter_comment'),
                validator: null,
                controller: _notesController,
              ),
              const SizedBox(height: 18),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 120,
                    height: 38,
                    child: CustomButton(
                      text: context.translate('cancel'),
                      isPrimary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    height: 38,
                    child: CustomButton(
                      text: context.translate('save'),
                      isPrimary: true,
                      onPressed: _onSavePressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
