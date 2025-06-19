import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class AddIncomeBody extends StatefulWidget {
  final IncomeItem? incomeItem;
  final bool isEdit;
  const AddIncomeBody({
    super.key,
    this.incomeItem,
    this.isEdit = false,
  });

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
  // String? selectedFrequency;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.incomeItem != null) {
      _nameController.text = widget.incomeItem!.name;
      _commentController.text = widget.incomeItem!.comment;
      _amountController.text = widget.incomeItem!.amount.toString();
      _dateToReceiveController.text = widget.incomeItem!.dateToReceive;
      selectedCurrency = widget.incomeItem!.currency;
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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                child: Center(
                  child: Text(
                    context.translate(
                      widget.isEdit ? 'edit_income' : 'add_income',
                    ),
                    style: TextStyle(
                      fontSize: fontSize18,
                      color: LightColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // CustomLabelSelector(
              //   label: 'Frequency',
              //   hintText: 'Select frequency',
              //   validator: (final String? value) {
              //     if (value == null) {
              //       return 'Please select a frequency';
              //     }
              //     return null;
              //   },
              //   selectedValue: selectedFrequency,
              //   items: <String>[
              //     'Weekly',
              //     'Biweekly',
              //     'Monthly',
              //     'Yearly',
              //     'Specific Date',
              //   ],
              //   onChanged: (final String? value) {
              //     setState(() {
              //       selectedFrequency = value;
              //     });
              //   },
              // ),
              CustomLabelInput(
                label: context.translate('income_name'),
                hintText: context.translate('enter_income_name'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_income_name');
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
                    return context.translate('please_enter_comment');
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
                    return context.translate('please_select_currency');
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
                    return context.translate('please_enter_amount');
                  }
                  return null;
                },
                controller: _amountController,
              ),
              CustomLabelInput(
                label: context.translate('date_to_receive'),
                hintText: context.translate('enter_date_to_receive'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isCalendar: true,
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_date_to_receive');
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
                    width: 150,
                    height: 40,
                    child: CustomButton(
                      text: context.translate('cancel'),
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
                          //TODO: Validate and add/edit income integration
                          if (widget.isEdit) {
                            // Update the existing income item
                            // You can access the updated values here
                            // Example: Update logic here
                          } else {
                            // Add a new income item
                          }
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
