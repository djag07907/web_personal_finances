import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addIncome/add_income_page.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/pagination/pagination_widget.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class IncomesBody extends StatefulWidget {
  const IncomesBody({super.key});

  @override
  State<IncomesBody> createState() => _IncomesBodyState();
}

class _IncomesBodyState extends State<IncomesBody> {
  final List<IncomeItem> _incomeItems = <IncomeItem>[
    IncomeItem(
      id: '1',
      name: 'Salary',
      comment: 'Monthly Salary',
      currency: 'USD',
      amount: 3000,
      dateToReceive: '2023-10-01',
      status: true,
    ),
    IncomeItem(
      id: '2',
      name: 'Freelancing',
      comment: 'Web Development',
      currency: 'USD',
      amount: 1500,
      dateToReceive: '2023-10-15',
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
          title: context.translate('incomes'),
          body: CustomDataTable<IncomeItem>(
            data: _incomeItems,
            dataColumns: <String>[
              context.translate('id').toUpperCase(),
              context.translate('name'),
              context.translate('comment'),
              context.translate('currency'),
              context.translate('amount'),
              context.translate('date_to_receive'),
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
                          text: context.translate('add_income'),
                          isPrimary: true,
                          onPressed: _addIncome,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            rowBuilder: (
              final IncomeItem data,
            ) {
              return <Widget>[
                Text(data.id),
                Text(data.name),
                Text(data.comment),
                Text(data.currency),
                Text(data.amount.toString()),
                Text(data.dateToReceive),
                CustomChipStatus(
                  isActive: data.status,
                ),
              ];
            },
            popupMenuBuilder: (
              final IncomeItem item,
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
                      _editIncome(
                        item,
                      );
                      break;
                    case CustomOptions.delete:
                      _removeIncome(item);
                      break;

                    case CustomOptions.activate:
                      _activateIncome(item);
                      break;

                    case CustomOptions.deactivate:
                      _deactivateIncome(item);
                      break;
                  }
                },
              );
            },
            paginator: PaginationWidget(
              currentPage: _currentPage,
              totalItems: _incomeItems.length,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (final int newPage) {
                setState(() {
                  _currentPage = newPage;
                });
              },
            ),
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
          onPressed: (_currentPage + 1) * _itemsPerPage < _incomeItems.length
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

  Future<bool?> _showConfirmation(
    final BuildContext context,
    final String title,
    final String content,
  ) {
    return showConfirmationDialog(context, title, content);
  }

  void _addIncome() {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          backgroundColor: white,
          child: AddIncomePage(),
        );
      },
    );
  }

  void _editIncome(final IncomeItem item) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          backgroundColor: white,
          child: AddIncomePage(incomeItem: item, isEdit: true),
        );
      },
    );
  }

  void _removeIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      'Confirm Removal',
      'Are you sure you want to remove this income?',
    );
    if (confirmed == true) {
      setState(() {
        _incomeItems.remove(item);
      });
      showSnackbar(context, 'Income removed successfully.');
    }
  }

  void _activateIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      'Confirm Activation',
      'Are you sure you want to activate this income?',
    );
    if (confirmed == true) {
      setState(() {
        // item.status = true;
      });
      showSnackbar(context, 'Income activated successfully.');
    }
  }

  void _deactivateIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      'Confirm Deactivation',
      'Are you sure you want to deactivate this income?',
    );
    if (confirmed == true) {
      setState(() {
        // item.status = false;
      });
      showSnackbar(context, 'Income deactivated successfully.');
    }
  }
}
