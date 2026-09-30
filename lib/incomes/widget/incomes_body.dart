import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_tag.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/drawer/drawer_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/layout/empty_content_widget.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/pagination/pagination_widget.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/incomes/bloc/incomes_bloc.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'incomes_form.dart';
part 'income_stat_card.dart';

class IncomesBody extends StatefulWidget {
  const IncomesBody({super.key});

  @override
  State<IncomesBody> createState() => _IncomesBodyState();
}

class _IncomesBodyState extends State<IncomesBody> {
  late IncomesBloc _incomesBloc;
  List<IncomeItem> _incomeItems = <IncomeItem>[];
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  bool _showDrawer = false;
  IncomeItem? _editingItem;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _incomesBloc = context.read<IncomesBloc>();
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    _incomesBloc.add(IncomesFetched(userId: currentUid));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _incomesBloc = context.read<IncomesBloc>();
  }

  @override
  Widget build(final BuildContext context) {
    return BlocListener<IncomesBloc, BaseState>(
      listener: (final BuildContext context, final BaseState state) {
        if (state is IncomesSuccess) {
          setState(() {
            _incomeItems = state.incomes;
          });
        }
      },
      child: Stack(
        children: <Widget>[
          CustomCardBody(
            isMain: false,
            isMenu: true,
            title: context.translate('incomes'),
            description: 'Track and manage all your income sources',
            buttonText: context.translate('add_income'),
            buttonIsPrimary: true,
            buttonIsAdd: true,
            onButtonPressed: _addIncome,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCards(context),
                Expanded(
                  child: _incomeItems.isEmpty
                      ? EmptyContentWidget(
                          icon: Icons.payments_outlined,
                          title: 'No incomes registered yet',
                          subtitle:
                              'Start tracking your revenues by adding your first income entry.',
                          actionLabel: context.translate('add_income'),
                          onAction: _addIncome,
                        )
                      : CustomDataTable<IncomeItem>(
                          data: _incomeItems,
                          showToolbar: true,
                          searchHint: 'Search by name, category, or amount...',
                          onSearch: () {},
                          onFilter: () {},
                          onExport: () {},
                          dataColumns: <String>[
                            context.translate('name'),
                            context.translate('frequency'),
                            context.translate('comment'),
                            context.translate('currency'),
                            context.translate('amount'),
                            context.translate('date_to_receive'),
                            context.translate('status'),
                          ],
                          rowBuilder: (final IncomeItem data) {
                            return <Widget>[
                              Text(data.name),
                              Text(data.frequency.toTranslate(context)),
                              Text(data.comment),
                              Text(data.currency),
                              Text(data.amount.toStringAsFixed(2)),
                              Text(data.dateToReceive),
                              CustomChipStatus(isActive: data.status),
                            ];
                          },
                          popupMenuBuilder: (final IncomeItem item) {
                            return PrimaryPopupMenu<CustomOptions>(
                              popupItems: <PopupItem<CustomOptions>>[
                                PopupItem<CustomOptions>(
                                  title: CustomOptions.edit.toTranslate(
                                    context,
                                  ),
                                  value: CustomOptions.edit,
                                ),
                                PopupItem<CustomOptions>(
                                  title: CustomOptions.delete.toTranslate(
                                    context,
                                  ),
                                  value: CustomOptions.delete,
                                ),
                                if (!item.status)
                                  PopupItem<CustomOptions>(
                                    title: CustomOptions.activate.toTranslate(
                                      context,
                                    ),
                                    value: CustomOptions.activate,
                                  ),
                                if (item.status)
                                  PopupItem<CustomOptions>(
                                    title: CustomOptions.deactivate.toTranslate(
                                      context,
                                    ),
                                    value: CustomOptions.deactivate,
                                  ),
                              ],
                              tooltip: context.translate('options'),
                              onSelect: (final CustomOptions option) {
                                Navigator.of(context).pop();
                                Future<void>.delayed(
                                  const Duration(milliseconds: 150),
                                  () {
                                    switch (option) {
                                      case CustomOptions.edit:
                                        _editIncome(item);
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
                child: Container(color: black.withValues(alpha: 0.5)),
              ),
            ),
          if (_showDrawer)
            Positioned.fill(
              child: DrawerWidget(
                title: context.translate(
                  _isEditing ? 'edit_income' : 'add_income',
                ),
                onClose: () {
                  setState(() {
                    _showDrawer = false;
                  });
                },
                child: FormWidget(
                  incomeItem: _editingItem,
                  isEdit: _isEditing,
                  onSave: (final IncomeItem item) {
                    if (_isEditing) {
                      _incomesBloc.add(IncomesUpdated(incomeItem: item));
                    } else {
                      _incomesBloc.add(IncomesAdded(incomeItem: item));
                    }
                    showSnackbar(
                      context,
                      context.translate('income_saved_successfully'),
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
          BlocBuilder<IncomesBloc, BaseState>(
            buildWhen: (final BaseState previous, final BaseState current) {
              return (previous is IncomesInProgress) !=
                  (current is IncomesInProgress);
            },
            builder: (final BuildContext context, final BaseState state) {
              if (state is IncomesInProgress && !_showDrawer) {
                return const Loader();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
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
      },
      onSecondaryButtonTap: () {
        confirmed = false;
      },
    );
    return Future<bool>.value(confirmed);
  }

  void _addIncome() {
    setState(() {
      _showDrawer = true;
      _editingItem = null;
      _isEditing = false;
    });
  }

  void _editIncome(final IncomeItem item) {
    setState(() {
      _showDrawer = true;
      _editingItem = item;
      _isEditing = true;
    });
  }

  void _removeIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_income_delete'),
    );
    if (confirmed == true) {
      _incomesBloc.add(IncomesDeleted(id: item.id, userId: item.userId));
      showSnackbar(context, context.translate('income_deleted'));
    }
  }

  void _activateIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_activation'),
      context.translate('confirm_income_activation'),
    );
    if (confirmed == true) {
      final IncomeItem updated = IncomeItem(
        id: item.id,
        userId: item.userId,
        name: item.name,
        comment: item.comment,
        currency: item.currency,
        amount: item.amount,
        dateToReceive: item.dateToReceive,
        status: true,
        createdDate: item.createdDate,
        frequency: item.frequency,
        tags: item.tags,
      );
      _incomesBloc.add(IncomesUpdated(incomeItem: updated));
      showSnackbar(context, context.translate('income_activated'));
    }
  }

  void _deactivateIncome(final IncomeItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_deactivation'),
      context.translate('confirm_income_deactivation'),
    );
    if (confirmed == true) {
      final IncomeItem updated = IncomeItem(
        id: item.id,
        userId: item.userId,
        name: item.name,
        comment: item.comment,
        currency: item.currency,
        amount: item.amount,
        dateToReceive: item.dateToReceive,
        status: false,
        createdDate: item.createdDate,
        frequency: item.frequency,
        tags: item.tags,
      );
      _incomesBloc.add(IncomesUpdated(incomeItem: updated));
      showSnackbar(context, context.translate('income_deactivated'));
    }
  }

  Widget _buildStatCards(final BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 800;

    final double totalReceived = _incomeItems
        .where((final IncomeItem item) => item.status)
        .fold(
          0.0,
          (final double sum, final IncomeItem item) => sum + item.amount,
        );
    final double totalPending = _incomeItems
        .where((final IncomeItem item) => !item.status)
        .fold(
          0.0,
          (final double sum, final IncomeItem item) => sum + item.amount,
        );
    // final int pendingCount = _incomeItems
    //     .where((final IncomeItem item) => !item.status)
    //     .length;

    if (isSmallScreen) {
      return Column(
        children: <Widget>[
          IncomeStatCard(
            title: 'Total Received',
            amount: '\u0024${totalReceived.toStringAsFixed(2)}',
            // changePercent: '5.2',
            isPositive: true,
            icon: Icons.payments,
          ),
          const SizedBox(height: 12),
          IncomeStatCard(
            title: 'Pending',
            amount: '\u0024${totalPending.toStringAsFixed(2)}',
            // subtitle: pendingCount > 0 ? '$pendingCount pending' : null,
            // changePercent: '1.2',
            isPositive: true,
            icon: Icons.pending_actions,
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: IncomeStatCard(
            title: 'Total Received',
            amount: '\u0024${totalReceived.toStringAsFixed(2)}',
            // changePercent: '5.2',
            isPositive: true,
            icon: Icons.payments,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: IncomeStatCard(
            title: 'Pending',
            amount: '\u0024${totalPending.toStringAsFixed(2)}',
            // subtitle: pendingCount > 0 ? '$pendingCount pending' : null,
            // changePercent: '1.2',
            isPositive: true,
            icon: Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
