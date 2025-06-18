import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addExpense/add_expense_page.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class ExpensesBody extends StatefulWidget {
  const ExpensesBody({super.key});

  @override
  State<ExpensesBody> createState() => _ExpensesBodyState();
}

class _ExpensesBodyState extends State<ExpensesBody> {
  final List<ExpenseItem> _expenseItems = <ExpenseItem>[
    ExpenseItem(
      id: '1',
      name: 'Rent',
      comment: 'Monthly Rent',
      currency: 'USD',
      amount: 1200,
      dateDue: '2023-10-01',
      status: true,
    ),
    ExpenseItem(
      id: '2',
      name: 'Freelancing',
      comment: 'Web Development',
      currency: 'USD',
      amount: 1500,
      dateDue: '2023-10-15',
      status: false,
    ),
  ];

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('expenses'),
          body: CustomDataTable<ExpenseItem>(
            data: _expenseItems,
            dataColumns: <String>[
              context.translate('id').toUpperCase(),
              context.translate('name'),
              context.translate('comment'),
              context.translate('currency'),
              context.translate('amount'),
              context.translate('date_due'),
              context.translate('status'),
            ],
            headers: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 180,
                        height: 40,
                        child: CustomButton(
                          text: context.translate('add_expense'),
                          isPrimary: true,
                          onPressed: _addExpense,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            rowBuilder: (
              final ExpenseItem data,
            ) {
              return <Widget>[
                Text(data.id),
                Text(data.name),
                Text(data.comment),
                Text(data.currency),
                Text(data.amount.toString()),
                Text(data.dateDue),
                CustomChipStatus(
                  isActive: data.status,
                ),
              ];
            },
            popupMenuBuilder: (
              final ExpenseItem item,
            ) {
              return PrimaryPopupMenu<CustomOptions>(
                popupItems: <PopupItem<CustomOptions>>[
                  PopupItem<CustomOptions>(
                    title: CustomOptions.edit.toTranslate(context),
                    value: CustomOptions.edit,
                  ),
                  PopupItem<CustomOptions>(
                    title: CustomOptions.delete.toTranslate(context),
                    value: CustomOptions.delete,
                  ),
                  if (!item.status)
                    PopupItem<CustomOptions>(
                      title: CustomOptions.activate.toTranslate(context),
                      value: CustomOptions.activate,
                    ),
                  if (item.status)
                    PopupItem<CustomOptions>(
                      title: CustomOptions.deactivate.toTranslate(context),
                      value: CustomOptions.deactivate,
                    ),
                ],
                tooltip: context.translate('options'),
                onSelect: (
                  final CustomOptions option,
                ) {
                  switch (option) {
                    case CustomOptions.edit:
                      // _editExpense(
                      // isEdit: true,
                      // );
                      break;
                    case CustomOptions.delete:
                      // _removeExpense();
                      break;

                    case CustomOptions.activate:
                      // _confirmationActivateDialog();
                      break;

                    case CustomOptions.deactivate:
                      // _confirmationInactivateDialog();
                      break;
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        Text('Page ${_currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: (_currentPage + 1) * _itemsPerPage < _expenseItems.length
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  void _addExpense() {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          backgroundColor: white,
          child: AddExpensePage(),
        );
      },
    );
  }

  void _editExpense(final ExpenseItem item) {
    // Logic to open the right side menu with the selected expense item data
    showSnackbar(context, 'Edit Expense functionality not implemented yet.');
  }

  void _removeExpense(final ExpenseItem item) async {
    final bool? confirmed = await showConfirmationDialog(
      context,
      'Confirm Removal',
      'Are you sure you want to remove this expense?',
    );
    if (confirmed == true) {
      setState(() {
        _expenseItems.remove(item);
      });
      showSnackbar(context, 'Expense removed successfully.');
    }
  }
}
