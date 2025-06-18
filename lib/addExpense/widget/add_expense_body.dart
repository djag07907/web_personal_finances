import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class AddExpenseBody extends StatefulWidget {
  const AddExpenseBody({super.key});

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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                child: Center(
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: fontSize18,
                      color: LightColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              CustomLabelSelector(
                label: 'Frequency',
                hintText: 'Select frequency',
                validator: (final String? value) {
                  if (value == null) {
                    return 'Please select a frequency';
                  }
                  return null;
                },
                selectedValue: selectedFrequency,
                items: <String>[
                  'Weekly',
                  'Biweekly',
                  'Monthly',
                  'Yearly',
                  'Specific Date',
                ],
                onChanged: (final String? value) {
                  setState(() {
                    selectedFrequency = value;
                  });
                },
              ),
              CustomLabelInput(
                label: 'Expense Name',
                hintText: 'Enter expense name',
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expense name';
                  }
                  return null;
                },
                controller: _nameController,
              ),
              CustomLabelInput(
                label: 'Comment',
                hintText: 'Enter comment',
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
                controller: _commentController,
              ),
              CustomLabelSelector(
                label: 'Currency',
                hintText: 'Select currency',
                validator: (final String? value) {
                  if (value == null) {
                    return 'Please select a currency';
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
                label: 'Amount',
                hintText: 'Enter amount',
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <MoneyInputFormatter>[
                  MoneyInputFormatter(),
                ],
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                controller: _amountController,
              ),
              CustomLabelInput(
                label: 'Date to Receive',
                hintText: 'Enter due date to pay the expense',
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isCalendar: true,
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a due date to pay the expense';
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
                    width: 120,
                    child: CustomButton(
                      text: 'Cancel',
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      text: 'Save',
                      isPrimary: true,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          //TODO: Validate and add expense integration
                          Navigator.of(context).pop();
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
