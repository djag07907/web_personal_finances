import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/drawer/drawer_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/pagination/pagination_widget.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

part 'form_widget.dart';

class AccountsReceivableBody extends StatefulWidget {
  const AccountsReceivableBody({super.key});

  @override
  State<AccountsReceivableBody> createState() => _AccountsReceivableBodyState();
}

class _AccountsReceivableBodyState extends State<AccountsReceivableBody> {
  final List<AccountReceivableItem> _accountsReceivableItems =
      <AccountReceivableItem>[
    AccountReceivableItem(
      id: '1',
      debtorName: 'Juan Perez',
      description: 'Money owed for services',
      currency: 'USD',
      amount: 3000,
      dueDate: DateTime.parse('2023-10-01'),
      receivedDate: DateTime.parse('2023-10-01'),
      isReceived: true,
    ),
    AccountReceivableItem(
      id: '2',
      debtorName: 'Carlos Lopez',
      description: 'Money owed for goods',
      currency: 'HNL',
      amount: 5000,
      dueDate: DateTime.parse('2023-10-01'),
      receivedDate: DateTime.parse('2023-10-01'),
      isReceived: false,
    ),
  ];

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  bool _showDrawer = false;
  AccountReceivableItem? _editingItem;
  bool _isEditing = false;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('accounts_receivable'),
          body: CustomDataTable<AccountReceivableItem>(
            data: _accountsReceivableItems,
            dataColumns: <String>[
              context.translate('id').toUpperCase(),
              context.translate('debtor_name'),
              context.translate('description'),
              context.translate('currency'),
              context.translate('amount'),
              context.translate('date_received'),
              context.translate('is_received'),
            ],
            headers: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: 265,
                        height: 40,
                        child: CustomButton(
                          text: context.translate('add_account_receivable'),
                          isPrimary: true,
                          onPressed: _addAccountReceivable,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            rowBuilder: (
              final AccountReceivableItem data,
            ) {
              return <Widget>[
                Text(data.id),
                Text(data.debtorName),
                Text(data.description),
                Text(data.currency),
                Text(data.amount.toString()),
                Text(data.dueDate.toString()),
                SizedBox(
                  width: 120,
                  height: 26,
                  child: CustomChipStatus(
                    isActive: data.isReceived,
                    isAccount: true,
                  ),
                ),
              ];
            },
            popupMenuBuilder: (
              final AccountReceivableItem item,
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
                  if (!item.isReceived)
                    PopupItem<CustomOptions>(
                      title: CustomOptions.activate.toTranslate(context),
                      value: CustomOptions.activate,
                    ),
                  if (item.isReceived)
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
                          _editAccountReceivable(item);
                          break;
                        case CustomOptions.delete:
                          _removeAccountReceivable(item);
                          break;
                        case CustomOptions.activate:
                          _activateAccountReceivable(item);
                          break;
                        case CustomOptions.deactivate:
                          _deactivateAccountReceivable(item);
                          break;
                      }
                    },
                  );
                },
              );
            },
            paginator: PaginationWidget(
              currentPage: _currentPage,
              totalItems: _accountsReceivableItems.length,
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
                _isEditing
                    ? 'edit_account_receivable'
                    : 'add_account_receivable',
              ),
              onClose: () {
                setState(() {
                  _showDrawer = false;
                });
              },
              child: FormWidget(
                accountReceivableItem: _editingItem,
                isEdit: _isEditing,
                onSave: (final AccountReceivableItem item) {
                  setState(() {
                    if (_isEditing) {
                      final int index = _accountsReceivableItems.indexWhere(
                        (final AccountReceivableItem accountReceivableItem) =>
                            accountReceivableItem.id == item.id,
                      );
                      if (index != -1) {
                        _accountsReceivableItems[index] = item;
                      }
                    } else {
                      _accountsReceivableItems.add(item);
                    }
                    _showDrawer = false;
                  });
                  showSnackbar(
                    context,
                    context.translate('account_receivable_saved_successfully'),
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

  void _addAccountReceivable() {
    setState(() {
      _showDrawer = true;
      _editingItem = null;
      _isEditing = false;
    });
  }

  void _editAccountReceivable(final AccountReceivableItem item) {
    setState(() {
      _showDrawer = true;
      _editingItem = item;
      _isEditing = true;
    });
  }

  void _removeAccountReceivable(final AccountReceivableItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_account_receivable_delete'),
    );
    if (confirmed == true) {
      setState(() {
        _accountsReceivableItems.remove(item);
      });
      showSnackbar(context, context.translate('account_receivable_deleted'));
    }
  }

  void _activateAccountReceivable(final AccountReceivableItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_activation'),
      context.translate('confirm_account_receivable_activation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = true;
      });
      showSnackbar(context, context.translate('account_receivable_activated'));
    }
  }

  void _deactivateAccountReceivable(final AccountReceivableItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_deactivation'),
      context.translate('confirm_account_receivable_deactivation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = false;
      });
      showSnackbar(
          context, context.translate('account_receivable_deactivated'));
    }
  }
}
