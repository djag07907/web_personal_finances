import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addExpense/model/expense_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AddExpenseBody extends StatefulWidget {
  final ExpenseItem? expenseItem;
  final bool isEdit;
  final void Function(ExpenseItem) onSave;
  final VoidCallback onClose;

  const AddExpenseBody({
    super.key,
    this.expenseItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<AddExpenseBody> createState() => _AddExpenseBodyState();
}

class _AddExpenseBodyState extends State<AddExpenseBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateDueController = TextEditingController();
  late String expenseName;
  late String expenseComment;
  late double expenseAmount;
  String? selectedCurrency;
  String? selectedFrequency;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.expenseItem != null) {
      _nameController.text = widget.expenseItem!.name;
      _commentController.text = widget.expenseItem!.comment;
      _amountController.text = widget.expenseItem!.amount.toString();
      _dateDueController.text = widget.expenseItem!.dateDue;
      selectedCurrency = widget.expenseItem!.currency;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: white,
      ),
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomLabelSelector(
                label: context.translate('frequency'),
                hintText: context.translate('select_frequency'),
                validator: (final String? value) {
                  if (value == null) {
                    return context.translate('please_select_a_frequency');
                  }
                  return null;
                },
                selectedValue: selectedFrequency,
                items: <String>[
                  context.translate('weekly'),
                  context.translate('biweekly'),
                  context.translate('monthly'),
                  context.translate('yearly'),
                  context.translate('specific_date'),
                ],
                onChanged: (final String? value) {
                  setState(() {
                    selectedFrequency = value;
                  });
                },
              ),
              CustomLabelInput(
                label: context.translate('expense_name'),
                hintText: context.translate('enter_expense_name'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_expense_name');
                  }
                  return null;
                },
                controller: _nameController,
              ),
              CustomLabelInput(
                label: context.translate('comment'),
                hintText: context.translate('enter_comment'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_a_comment');
                  }
                  return null;
                },
                controller: _commentController,
              ),
              CustomLabelSelector(
                label: context.translate('currency'),
                hintText: context.translate('select_currency'),
                validator: (final String? value) {
                  if (value == null) {
                    return context.translate('please_select_a_currency');
                  }
                  return null;
                },
                selectedValue: selectedCurrency,
                items: <String>[
                  'USD',
                  'HNL',
                ],
                onChanged: (final String? value) {
                  setState(() {
                    selectedCurrency = value;
                  });
                },
              ),
              CustomLabelInput(
                label: context.translate('amount'),
                hintText: context.translate('enter_amount'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <MoneyInputFormatter>[
                  MoneyInputFormatter(),
                ],
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_an_amount');
                  }
                  return null;
                },
                controller: _amountController,
              ),
              CustomLabelInput(
                label: context.translate('date_to_receive'),
                hintText: context.translate('enter_due_date'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isCalendar: true,
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_a_due_date');
                  }
                  return null;
                },
                controller: _dateDueController,
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                spacing: 15.0,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: CustomButton(
                      text: context.translate('cancel'),
                      isPrimary: false,
                      onPressed: widget.onClose,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: CustomButton(
                      text: context.translate('save'),
                      isPrimary: true,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final ExpenseItem newItem = ExpenseItem(
                            id: widget.isEdit
                                ? widget.expenseItem!.id
                                : DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            name: _nameController.text,
                            comment: _commentController.text,
                            currency: selectedCurrency!,
                            amount: double.tryParse(
                                  _amountController.text.replaceAll(',', ''),
                                ) ??
                                0,
                            dateDue: _dateDueController.text,
                            status: true,
                          );

                          widget.onSave(newItem);
                          widget.onClose();
                        }
                      },
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
