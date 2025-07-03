import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addAccountToPay/add_account_to_pay_screen.dart';
import 'package:web_personal_finances/addAccountToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/drawer/drawer_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/pagination/pagination_widget.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class AccountsToPayBody extends StatefulWidget {
  const AccountsToPayBody({super.key});

  @override
  State<AccountsToPayBody> createState() => _AccountsToPayBodyState();
}

class _AccountsToPayBodyState extends State<AccountsToPayBody> {
  final List<AccountToPayItem> _accountsToPayItems = <AccountToPayItem>[
    AccountToPayItem(
      id: '1',
      creditorName: 'Juan Perez',
      description: 'Money owed for services',
      currency: 'USD',
      amount: 3000,
      dueDate: DateTime.parse('2023-10-01'),
      paymentDate: DateTime.parse('2023-10-01'),
      isPaid: true,
    ),
    AccountToPayItem(
      id: '2',
      creditorName: 'Carlos Lopez',
      description: 'Money owed for goods',
      currency: 'HNL',
      amount: 5000,
      dueDate: DateTime.parse('2023-10-01'),
      paymentDate: DateTime.parse('2023-10-01'),
      isPaid: false,
    ),
  ];

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  bool _showDrawer = false;
  AccountToPayItem? _editingItem;
  bool _isEditing = false;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('accounts_to_pay'),
          body: CustomDataTable<AccountToPayItem>(
            data: _accountsToPayItems,
            dataColumns: <String>[
              context.translate('id').toUpperCase(),
              context.translate('creditor_name'),
              context.translate('description'),
              context.translate('currency'),
              context.translate('amount'),
              context.translate('due_date'),
              context.translate('is_paid'),
            ],
            headers: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 260,
                        height: 40,
                        child: CustomButton(
                          text: context.translate('add_account_to_pay'),
                          isPrimary: true,
                          onPressed: _addAccountToPay,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            rowBuilder: (
              final AccountToPayItem data,
            ) {
              return <Widget>[
                Text(data.id),
                Text(data.creditorName),
                Text(data.description),
                Text(data.currency),
                Text(data.amount.toString()),
                Text(data.dueDate.toString()),
                SizedBox(
                  width: 120,
                  height: 26,
                  child: CustomChipStatus(
                    isActive: data.isPaid,
                    isAccount: true,
                  ),
                ),
              ];
            },
            popupMenuBuilder: (
              final AccountToPayItem item,
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
                  if (!item.isPaid)
                    PopupItem<CustomOptions>(
                      title: CustomOptions.activate.toTranslate(context),
                      value: CustomOptions.activate,
                    ),
                  if (item.isPaid)
                    PopupItem<CustomOptions>(
                      title: CustomOptions.deactivate.toTranslate(context),
                      value: CustomOptions.deactivate,
                    ),
                ],
                tooltip: context.translate('options'),
                onSelect: (
                  final CustomOptions option,
                ) {
                  Navigator.of(context).pop();
                  Future<void>.delayed(
                    const Duration(milliseconds: 150),
                    () {
                      switch (option) {
                        case CustomOptions.edit:
                          _editAccountToPay(item);
                          break;
                        case CustomOptions.delete:
                          _removeAccountToPay(item);
                          break;
                        case CustomOptions.activate:
                          _activateAccountToPay(item);
                          break;
                        case CustomOptions.deactivate:
                          _deactivateAccountToPay(item);
                          break;
                      }
                    },
                  );
                },
              );
            },
            paginator: PaginationWidget(
              currentPage: _currentPage,
              totalItems: _accountsToPayItems.length,
              itemsPerPage: _itemsPerPage,
              onPageChanged: (final int newPage) {
                setState(() {
                  _currentPage = newPage;
                });
              },
            ),
          ),
        ),
        if (_showDrawer)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showDrawer = false;
                });
              },
              child: Container(
                color: black.withValues(alpha: 0.5),
              ),
            ),
          ),
        if (_showDrawer)
          Positioned.fill(
            child: DrawerWidget(
              title: context.translate(
                _isEditing ? 'edit_account_to_pay' : 'add_account_to_pay',
              ),
              onClose: () {
                setState(() {
                  _showDrawer = false;
                });
              },
              child: AddAccountToPayScreen(
                accountToPayItem: _editingItem,
                isEdit: _isEditing,
                onSave: (final AccountToPayItem item) {
                  setState(() {
                    if (_isEditing) {
                      final int index = _accountsToPayItems.indexWhere(
                        (final AccountToPayItem accountToPayItem) =>
                            accountToPayItem.id == item.id,
                      );
                      if (index != -1) {
                        _accountsToPayItems[index] = item;
                      }
                    } else {
                      _accountsToPayItems.add(item);
                    }
                    _showDrawer = false;
                  });
                  showSnackbar(
                    context,
                    context.translate('account_to_pay_saved_successfully'),
                  );
                },
                onClose: () {
                  setState(() {
                    _showDrawer = false;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Future<bool?> _showConfirmation(
    final BuildContext context,
    final String title,
    final String content,
  ) {
    bool? confirmed;
    CustomConfirmationDialog.showCustomConfirmationDialog(
      context,
      confirmationText: content,
      onPrimaryButtonTap: () {
        confirmed = true;
        // Navigator.of(context).pop();
      },
      onSecondaryButtonTap: () {
        confirmed = false;
      },
    );
    return Future<bool>.value(confirmed);
  }

  void _addAccountToPay() {
    setState(() {
      _showDrawer = true;
      _editingItem = null;
      _isEditing = false;
    });
  }

  void _editAccountToPay(final AccountToPayItem item) {
    setState(() {
      _showDrawer = true;
      _editingItem = item;
      _isEditing = true;
    });
  }

  void _removeAccountToPay(final AccountToPayItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_account_to_pay_delete'),
    );
    if (confirmed == true) {
      setState(() {
        _accountsToPayItems.remove(item);
      });
      showSnackbar(context, context.translate('account_to_pay_deleted'));
    }
  }

  void _activateAccountToPay(final AccountToPayItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_activation'),
      context.translate('confirm_account_to_pay_activation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = true;
      });
      showSnackbar(context, context.translate('account_to_pay_activated'));
    }
  }

  void _deactivateAccountToPay(final AccountToPayItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_deactivation'),
      context.translate('confirm_account_to_pay_deactivation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = false;
      });
      showSnackbar(context, context.translate('account_to_pay_deactivated'));
    }
  }
}
