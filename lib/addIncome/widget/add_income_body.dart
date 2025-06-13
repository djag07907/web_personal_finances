import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class AddIncomeBody extends StatefulWidget {
  const AddIncomeBody({super.key});

  @override
  State<AddIncomeBody> createState() => _AddIncomeBodyState();
}

class _AddIncomeBodyState extends State<AddIncomeBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateToReceiveController =
      TextEditingController();
  late String incomeName;
  late String incomeComment;
  late double incomeAmount;
  String? selectedCurrency;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ),
              child: Center(
                child: Text(
                  'ADD_INCOME',
                  style: TextStyle(
                    fontSize: fontSize18,
                    color: LightColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            CustomLabelInput(
              label: 'Income Name',
              hintText: 'Enter income name',
              validator: (final String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter income name';
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
              hintText: 'Enter date to receive the income',
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              // inputFormatters: <MoneyInputFormatter>[
              //   MoneyInputFormatter(),
              // ],
              validator: (final String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a date to receive the income';
                }
                return null;
              },
              controller: _dateToReceiveController,
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
                        //TODO: Validate and add income integration
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
    );
  }
}
