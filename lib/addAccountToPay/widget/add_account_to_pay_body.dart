import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addAccountToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AddAccountToPayBody extends StatefulWidget {
  final AccountToPayItem? accountToPayItem;
  final bool isEdit;
  final void Function(AccountToPayItem) onSave;
  final VoidCallback onClose;

  const AddAccountToPayBody({
    super.key,
    this.accountToPayItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<AddAccountToPayBody> createState() => _AddAccountToPayBodyState();
}

class _AddAccountToPayBodyState extends State<AddAccountToPayBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateToReceiveController =
      TextEditingController();
  late String accountToPayName;
  late String accountToPayDescription;
  late double accountToPayAmount;
  String? selectedCurrency;
  // String? selectedFrequency;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.accountToPayItem != null) {
      _nameController.text = widget.accountToPayItem!.creditorName;
      _commentController.text = widget.accountToPayItem!.description;
      _amountController.text = widget.accountToPayItem!.amount.toString();
      _dateToReceiveController.text = widget.accountToPayItem!.dueDate;
      selectedCurrency = widget.accountToPayItem!.currency;
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
              CustomLabelInput(
                label: context.translate('creditor_name'),
                hintText: context.translate('enter_creditor_name'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_creditor_name');
                  }
                  return null;
                },
                controller: _nameController,
              ),
              CustomLabelInput(
                label: context.translate('description'),
                hintText: context.translate('enter_description'),
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_description');
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
                label: context.translate('date_due'),
                hintText: context.translate('enter_date_due'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isCalendar: true,
                validator: (final String? value) {
                  if (value == null || value.isEmpty) {
                    return context.translate('please_enter_date_due');
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
                          final AccountToPayItem newItem = AccountToPayItem(
                            id: widget.isEdit
                                ? widget.accountToPayItem!.id
                                : DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            creditorName: _nameController.text,
                            description: _commentController.text,
                            currency: selectedCurrency!,
                            amount: double.tryParse(
                                  _amountController.text.replaceAll(',', ''),
                                ) ??
                                0,
                            dueDate: _dateToReceiveController.text,
                            isPaid: true,
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
