import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addSavings/model/saving_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AddSavingBody extends StatefulWidget {
  final SavingItem? savingItem;
  final bool isEdit;
  final void Function(SavingItem) onSave;
  final VoidCallback onClose;

  const AddSavingBody({
    super.key,
    this.savingItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<AddSavingBody> createState() => _AddSavingBodyState();
}

class _AddSavingBodyState extends State<AddSavingBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();

  late String incomeName;
  late String incomeComment;
  late double incomeAmount;
  String? selectedCurrency;
  // String? selectedFrequency;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.savingItem != null) {
      _nameController.text = widget.savingItem!.name;
      _commentController.text = widget.savingItem!.comment;
      _amountController.text = widget.savingItem!.amount.toString();
      _goalAmountController.text = widget.savingItem!.goalAmount.toString();
      selectedCurrency = widget.savingItem!.currency;
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
                label: context.translate('saving_name'),
                hintText: context.translate('enter_saving_name'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_saving_name');
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
                label: context.translate('goal_amount'),
                hintText: context.translate('enter_goal_amount'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: <MoneyInputFormatter>[
                  MoneyInputFormatter(),
                ],
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_goal_amount');
                  }
                  return null;
                },
                controller: _goalAmountController,
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
                          final SavingItem newItem = SavingItem(
                            id: widget.isEdit
                                ? widget.savingItem!.id
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
                            goalAmount: double.tryParse(
                                  _goalAmountController.text
                                      .replaceAll(',', ''),
                                ) ??
                                0,
                            isGoalReached: true,
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
