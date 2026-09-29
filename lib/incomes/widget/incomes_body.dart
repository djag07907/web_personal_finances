import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_tag.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/incomes/bloc/incomes_bloc.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
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
import 'package:web_personal_finances/resources/constants.dart';

part 'form_widget.dart';
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
    _initializeMockupData();
    _incomesBloc.add(IncomesFetched());
  }

  void _initializeMockupData() {
    _incomeItems = <IncomeItem>[
      IncomeItem(
        id: '1',
        name: 'Monthly Salary - Tech Corp',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'Full-time job salary',
        currency: 'USD',
        amount: 5500.00,
        dateToReceive: '2024-01-15',
        status: true,
      ),
      IncomeItem(
        id: '2',
        name: 'Freelance Web Design - Client A',
        frequency: CustomFrequencyOptions.once,
        comment: 'Website redesign project',
        currency: 'USD',
        amount: 1200.00,
        dateToReceive: '2024-01-20',
        status: true,
      ),
      IncomeItem(
        id: '3',
        name: 'Stock Dividends - Portfolio',
        frequency: CustomFrequencyOptions.yearly,
        comment: 'Q1 dividend payment',
        currency: 'USD',
        amount: 350.00,
        dateToReceive: '2024-01-10',
        status: true,
      ),
      IncomeItem(
        id: '4',
        name: 'Rental Income - Apartment',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'Downtown apartment rent',
        currency: 'USD',
        amount: 1500.00,
        dateToReceive: '2024-01-01',
        status: true,
      ),
      IncomeItem(
        id: '5',
        name: 'Consulting Fee - Startup XYZ',
        frequency: CustomFrequencyOptions.once,
        comment: 'Technical consultation',
        currency: 'USD',
        amount: 800.00,
        dateToReceive: '2024-01-25',
        status: false,
      ),
      IncomeItem(
        id: '6',
        name: 'YouTube Ad Revenue',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'Content monetization',
        currency: 'USD',
        amount: 450.00,
        dateToReceive: '2024-01-28',
        status: true,
      ),
      IncomeItem(
        id: '7',
        name: 'Online Course Sales',
        frequency: CustomFrequencyOptions.weekly,
        comment: 'Udemy course earnings',
        currency: 'USD',
        amount: 320.00,
        dateToReceive: '2024-01-18',
        status: true,
      ),
      IncomeItem(
        id: '8',
        name: 'Logo Design - Company B',
        frequency: CustomFrequencyOptions.once,
        comment: 'Brand identity project',
        currency: 'USD',
        amount: 600.00,
        dateToReceive: '2024-01-22',
        status: false,
      ),
      IncomeItem(
        id: '9',
        name: 'Bonus Payment - Tech Corp',
        frequency: CustomFrequencyOptions.once,
        comment: 'Annual performance bonus',
        currency: 'USD',
        amount: 2000.00,
        dateToReceive: '2024-01-30',
        status: true,
      ),
      IncomeItem(
        id: '10',
        name: 'Affiliate Commissions',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'Product referral earnings',
        currency: 'USD',
        amount: 275.00,
        dateToReceive: '2024-01-12',
        status: true,
      ),
      IncomeItem(
        id: '11',
        name: 'Photography Session',
        frequency: CustomFrequencyOptions.once,
        comment: 'Wedding photography',
        currency: 'USD',
        amount: 950.00,
        dateToReceive: '2024-01-08',
        status: true,
      ),
      IncomeItem(
        id: '12',
        name: 'App Development - Freelance',
        frequency: CustomFrequencyOptions.once,
        comment: 'Mobile app project',
        currency: 'USD',
        amount: 3500.00,
        dateToReceive: '2024-02-05',
        status: false,
      ),
      IncomeItem(
        id: '13',
        name: 'Blog Sponsorship',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'Tech blog sponsored content',
        currency: 'USD',
        amount: 500.00,
        dateToReceive: '2024-01-15',
        status: true,
      ),
      IncomeItem(
        id: '14',
        name: 'Graphic Design - Client C',
        frequency: CustomFrequencyOptions.once,
        comment: 'Social media templates',
        currency: 'USD',
        amount: 400.00,
        dateToReceive: '2024-01-27',
        status: false,
      ),
      IncomeItem(
        id: '15',
        name: 'Side Business Profit',
        frequency: CustomFrequencyOptions.monthly,
        comment: 'E-commerce store revenue',
        currency: 'USD',
        amount: 850.00,
        dateToReceive: '2024-01-31',
        status: true,
      ),
    ];
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
                  child: CustomDataTable<IncomeItem>(
                    data: _incomeItems,
                    showToolbar: true,
                    searchHint: 'Search by name, category, or amount...',
                    onSearch: () {
                      // TODO: Implement search
                      print('Search triggered');
                    },
                    onFilter: () {
                      // TODO: Implement filter
                      print('Filter triggered');
                    },
                    onExport: () {
                      // TODO: Implement export
                      print('Export triggered');
                    },
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
                        Text(data.amount.toString()),
                        Text(data.dateToReceive.toString()),
                        CustomChipStatus(isActive: data.status),
                      ];
                    },
                    popupMenuBuilder: (final IncomeItem item) {
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
                return Container(
                  color: black.withValues(alpha: 0.5),
                  child: const Center(child: Loader()),
                );
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
      setState(() {
        _incomeItems.remove(item);
      });
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
      setState(() {
        // item.status = true;
      });
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
      setState(() {
        // item.status = false;
      });
      showSnackbar(context, context.translate('income_deactivated'));
    }
  }

  Widget _buildStatCards(final BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 900;

    // Calculate totals
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
    final int pendingCount = _incomeItems
        .where((final IncomeItem item) => !item.status)
        .length;

    if (isSmallScreen) {
      return Column(
        children: <Widget>[
          IncomeStatCard(
            title: 'Total Received',
            amount: '\u0024${totalReceived.toStringAsFixed(2)}',
            subtitle: 'vs last month',
            changePercent: '5.2',
            isPositive: true,
            icon: Icons.payments,
          ),
          SizedBox(height: 12),
          IncomeStatCard(
            title: 'Pending',
            amount: '\u0024${totalPending.toStringAsFixed(2)}',
            subtitle: '$pendingCount invoices overdue',
            changePercent: '1.2',
            isPositive: true,
            icon: Icons.pending_actions,
          ),
          SizedBox(height: 12),
          IncomeStatCard(
            title: 'Month Growth',
            amount: '+12%',
            subtitle: 'On track to goal',
            changePercent: '12',
            isPositive: true,
            icon: Icons.trending_up,
          ),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: IncomeStatCard(
            title: 'Total Received',
            amount: '\u0024${totalReceived.toStringAsFixed(2)}',
            subtitle: 'vs last month',
            changePercent: '5.2',
            isPositive: true,
            icon: Icons.payments,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: IncomeStatCard(
            title: 'Pending',
            amount: '\u0024${totalPending.toStringAsFixed(2)}',
            subtitle: '$pendingCount invoices overdue',
            changePercent: '1.2',
            isPositive: true,
            icon: Icons.pending_actions,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: IncomeStatCard(
            title: 'Month Growth',
            amount: '+12%',
            subtitle: 'On track to goal',
            changePercent: '12',
            isPositive: true,
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }
}
