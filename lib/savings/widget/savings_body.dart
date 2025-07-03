import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/addSavings/add_saving_screen.dart';
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
import 'package:web_personal_finances/savings/model/saving_item.dart';

class SavingsBody extends StatefulWidget {
  const SavingsBody({super.key});

  @override
  State<SavingsBody> createState() => _SavingsBodyState();
}

class _SavingsBodyState extends State<SavingsBody> {
  final List<SavingItem> _savingsItems = <SavingItem>[
    SavingItem(
      id: '1',
      name: 'Vacation Fund',
      comment: 'Family Trip',
      currency: 'USD',
      amount: 3000,
      goalAmount: 10000,
      status: true,
    ),
    SavingItem(
      id: '2',
      name: 'To buy a Car',
      comment: 'For the RAV4',
      currency: 'USD',
      amount: 1500,
      goalAmount: 9000,
      status: false,
    ),
  ];

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  bool _showDrawer = false;
  SavingItem? _editingItem;
  bool _isEditing = false;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('savings'),
          body: CustomDataTable<SavingItem>(
            data: _savingsItems,
            dataColumns: <String>[
              context.translate('id').toUpperCase(),
              context.translate('name'),
              context.translate('comment'),
              context.translate('currency'),
              context.translate('amount'),
              context.translate('goal_amount'),
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
                          text: context.translate('add_saving'),
                          isPrimary: true,
                          onPressed: _addSaving,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            rowBuilder: (
              final SavingItem data,
            ) {
              return <Widget>[
                Text(data.id),
                Text(data.name),
                Text(data.comment),
                Text(data.currency),
                Text(data.amount.toString()),
                Text(data.goalAmount.toString()),
                CustomChipStatus(
                  isActive: data.status,
                ),
              ];
            },
            popupMenuBuilder: (
              final SavingItem item,
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
                  Navigator.of(context).pop();
                  Future<void>.delayed(
                    const Duration(milliseconds: 150),
                    () {
                      switch (option) {
                        case CustomOptions.edit:
                          _editSaving(item);
                          break;
                        case CustomOptions.delete:
                          _removeSaving(item);
                          break;
                        case CustomOptions.activate:
                          _activateSaving(item);
                          break;
                        case CustomOptions.deactivate:
                          _deactivateSaving(item);
                          break;
                      }
                    },
                  );
                },
              );
            },
            paginator: PaginationWidget(
              currentPage: _currentPage,
              totalItems: _savingsItems.length,
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
              title:
                  context.translate(_isEditing ? 'edit_saving' : 'add_saving'),
              onClose: () {
                setState(() {
                  _showDrawer = false;
                });
              },
              child: AddSavingScreen(
                savingItem: _editingItem,
                isEdit: _isEditing,
                onSave: (final SavingItem item) {
                  setState(() {
                    if (_isEditing) {
                      final int index = _savingsItems.indexWhere(
                        (final SavingItem savingItem) =>
                            savingItem.id == item.id,
                      );
                      if (index != -1) {
                        _savingsItems[index] = item;
                      }
                    } else {
                      _savingsItems.add(item);
                    }
                    _showDrawer = false;
                  });
                  showSnackbar(
                    context,
                    context.translate('saving_saved_successfully'),
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

  void _addSaving() {
    setState(() {
      _showDrawer = true;
      _editingItem = null;
      _isEditing = false;
    });
  }

  void _editSaving(final SavingItem item) {
    setState(() {
      _showDrawer = true;
      _editingItem = item;
      _isEditing = true;
    });
  }

  void _removeSaving(final SavingItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_saving_delete'),
    );
    if (confirmed == true) {
      setState(() {
        _savingsItems.remove(item);
      });
      showSnackbar(context, context.translate('saving_deleted'));
    }
  }

  void _activateSaving(final SavingItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_activation'),
      context.translate('confirm_saving_activation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = true;
      });
      showSnackbar(context, context.translate('saving_activated'));
    }
  }

  void _deactivateSaving(final SavingItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_deactivation'),
      context.translate('confirm_saving_deactivation'),
    );
    if (confirmed == true) {
      setState(() {
        // item.status = false;
      });
      showSnackbar(context, context.translate('saving_deactivated'));
    }
  }
}
