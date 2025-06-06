import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

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
        color: LightColors.background,
      ),
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Text(
                'ADD_INCOME',
                style: TextStyle(color: LightColors.primary),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CustomButton(
                  text: 'Cancel',
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 8),
                CustomButton(
                  text: 'Save',
                  isPrimary: true,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String name = _nameController.text;
                      final String comment = _commentController.text;
                      final double amount =
                          double.tryParse(_amountController.text) ?? 0.0;
                      final String? currency = selectedCurrency;
                      // You might want to add the new income to the list or perform any other action
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
