import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsToPay/bloc/accounts_to_pay_bloc.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/cards/kpi_info_tooltip.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_tag.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/drawer/drawer_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/enum/custom_account_to_pay_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_payment_filters.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/layout/empty_content_widget.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/pagination/pagination_widget.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/commons/popupMenu/primary_popup_menu.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/commons/table/custom_data_table.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'account_to_pay_stat_card.dart';
part 'accounts_to_pay_form.dart';

class AccountsToPayBody extends StatefulWidget {
  const AccountsToPayBody({super.key});

  @override
  State<AccountsToPayBody> createState() => _AccountsToPayBodyState();
}

class _AccountsToPayBodyState extends State<AccountsToPayBody> {
  late AccountsToPayBloc _bloc;
  List<AccountToPayItem> _items = <AccountToPayItem>[];

  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  AccountToPayItem? _editingItem;
  bool _isEditing = false;

  UserModel? _currentUser;
  bool _showFilterPanel = false;
  String _searchQuery = emptyString;
  CustomPaymentFilters? _selectedPaymentFilter;
  CustomAccountToPayCategoryOptions? _selectedCategoryFilter;
  CustomFrequencyOptions? _selectedFrequencyFilter;
  bool? _selectedStatusFilter;
  String? _selectedDateFilter;

  String _formatDate(final DateTime date) =>
      DateFormat(dayMonthYearFormat).format(date);

  String _paymentLabel(
    final BuildContext context,
    final CustomPaymentFilters f,
  ) {
    switch (f) {
      case CustomPaymentFilters.pending:
        return context.translate('pending');
      case CustomPaymentFilters.overdue:
        return context.translate('overdue');
      case CustomPaymentFilters.paid:
        return context.translate('paid');
    }
  }

  CustomPaymentFilters _paymentStateOf(final AccountToPayItem item) {
    if (item.isPaid) {
      return CustomPaymentFilters.paid;
    }
    return AccountToPayUtils.isOverdue(item)
        ? CustomPaymentFilters.overdue
        : CustomPaymentFilters.pending;
  }

  List<AccountToPayItem> get _filteredItems {
    return _items.where((final AccountToPayItem item) {
      if (_searchQuery.isNotEmpty) {
        final String query = _searchQuery.toLowerCase().trim();
        final String activeText = context.translate('active').toLowerCase();
        final String inactiveText = context.translate('inactive').toLowerCase();
        final bool matches =
            item.creditorName.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.currency.toLowerCase().contains(query) ||
            item.amount.toString().contains(query) ||
            item.frequency.toTranslate(context).toLowerCase().contains(query) ||
            item.category.toTranslate(context).toLowerCase().contains(query) ||
            _formatDate(item.dueDate).contains(query) ||
            _paymentLabel(
              context,
              _paymentStateOf(item),
            ).toLowerCase().contains(query) ||
            item.tags.any(
              (final String tag) => tag.toLowerCase().contains(query),
            ) ||
            (item.status && activeText.contains(query)) ||
            (!item.status && inactiveText.contains(query));
        if (!matches) {
          return false;
        }
      }

      if (_selectedPaymentFilter != null &&
          _paymentStateOf(item) != _selectedPaymentFilter) {
        return false;
      }
      if (_selectedCategoryFilter != null &&
          item.category != _selectedCategoryFilter) {
        return false;
      }
      if (_selectedFrequencyFilter != null &&
          item.frequency != _selectedFrequencyFilter) {
        return false;
      }
      if (_selectedStatusFilter != null &&
          item.status != _selectedStatusFilter) {
        return false;
      }
      if (_selectedDateFilter != null &&
          _selectedDateFilter!.isNotEmpty &&
          _formatDate(item.dueDate) != _selectedDateFilter) {
        return false;
      }
      return true;
    }).toList()..sort(
      (final AccountToPayItem a, final AccountToPayItem b) =>
          a.dueDate.compareTo(b.dueDate),
    );
  }

  bool get _isFilterActive =>
      _selectedPaymentFilter != null ||
      _selectedCategoryFilter != null ||
      _selectedFrequencyFilter != null ||
      _selectedStatusFilter != null ||
      (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty);

  void _clearFilters({final bool includeSearch = false}) {
    setState(() {
      if (includeSearch) {
        _searchQuery = emptyString;
      }
      _selectedPaymentFilter = null;
      _selectedCategoryFilter = null;
      _selectedFrequencyFilter = null;
      _selectedStatusFilter = null;
      _selectedDateFilter = null;
      _currentPage = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AccountsToPayBloc>();
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    _bloc.add(AccountsToPayFetched(userId: currentUid));
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<AccountsToPayBloc>();
  }

  Future<void> _loadCurrentUser() async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;
    final UserRepository userRepository = context.read<UserRepository>();
    final UserModel? user = await userRepository.getUser(authUser.uid);
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Widget _buildInlineFilterPanel(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildPaymentSegmentedControl(context, isDark),
          const SizedBox(width: 8.0),
          _buildFilterDropdown<bool?>(
            isDark: isDark,
            hint: context.translate('status'),
            value: _selectedStatusFilter,
            allLabel:
                '${context.translate('all')} ${context.translate('status')}',
            options: <bool?, String>{
              true: context.translate('active'),
              false: context.translate('inactive'),
            },
            onChanged: (final bool? val) => _selectedStatusFilter = val,
          ),
          const SizedBox(width: 8.0),
          _buildFilterDropdown<CustomAccountToPayCategoryOptions?>(
            isDark: isDark,
            hint: context.translate('category'),
            value: _selectedCategoryFilter,
            allLabel:
                '${context.translate('all')} ${context.translate('category')}',
            options: <CustomAccountToPayCategoryOptions?, String>{
              for (final CustomAccountToPayCategoryOptions cat
                  in CustomAccountToPayCategoryOptions.values)
                cat: cat.toTranslate(context),
            },
            onChanged: (final CustomAccountToPayCategoryOptions? val) =>
                _selectedCategoryFilter = val,
          ),
          const SizedBox(width: 8.0),
          _buildFilterDropdown<CustomFrequencyOptions?>(
            isDark: isDark,
            hint: context.translate('frequency'),
            value: _selectedFrequencyFilter,
            allLabel:
                '${context.translate('all')} ${context.translate('frequency')}',
            options: <CustomFrequencyOptions?, String>{
              for (final CustomFrequencyOptions opt
                  in CustomFrequencyOptions.values)
                opt: opt.toTranslate(context),
            },
            onChanged: (final CustomFrequencyOptions? val) =>
                _selectedFrequencyFilter = val,
          ),
          const SizedBox(width: 8.0),
          _buildDatePickerButton(context, isDark),
          if (_isFilterActive) ...<Widget>[
            const SizedBox(width: 4.0),
            IconButton(
              tooltip: context.translate('clear_filters'),
              icon: Icon(
                Icons.clear_all,
                size: 20,
                color: isDark ? DarkColors.primary : LightColors.primary,
              ),
              onPressed: _clearFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required final bool isDark,
    required final String hint,
    required final T? value,
    required final String allLabel,
    required final Map<T, String> options,
    required final void Function(T? value) onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? DarkColors.textSecondary : greyHard,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            size: 18,
            color: isDark ? DarkColors.textSecondary : greyHard,
          ),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
          dropdownColor: isDark ? DarkColors.surface : Colors.white,
          items: <DropdownMenuItem<T?>>[
            DropdownMenuItem<T?>(value: null, child: Text(allLabel)),
            ...options.entries.map(
              (final MapEntry<T, String> entry) => DropdownMenuItem<T?>(
                value: entry.key,
                child: Text(entry.value),
              ),
            ),
          ],
          onChanged: (final T? val) {
            setState(() {
              onChanged(val);
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPaymentSegmentedControl(
    final BuildContext context,
    final bool isDark,
  ) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildSegmentItem(
            label: context.translate('all'),
            isSelected: _selectedPaymentFilter == null,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedPaymentFilter = null;
                _currentPage = 0;
              });
            },
          ),
          ...CustomPaymentFilters.values.map(
            (final CustomPaymentFilters f) => _buildSegmentItem(
              label: _paymentLabel(context, f),
              isSelected: _selectedPaymentFilter == f,
              isDark: isDark,
              onTap: () {
                setState(() {
                  _selectedPaymentFilter = f;
                  _currentPage = 0;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required final String label,
    required final bool isSelected,
    required final bool isDark,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? DarkColors.primary : LightColors.primary)
              : transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? white
                : (isDark ? DarkColors.textSecondary : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(final BuildContext context, final bool isDark) {
    final bool hasDate =
        _selectedDateFilter != null && _selectedDateFilter!.isNotEmpty;
    final Color primary = isDark ? DarkColors.primary : LightColors.primary;

    return InkWell(
      onTap: () async {
        final TextEditingController controller = TextEditingController(
          text: _selectedDateFilter ?? emptyString,
        );
        final CustomCalendarDialog calendar = CustomCalendarDialog();
        final DateTime? selectedDate = await calendar.showDateDialog(
          context: context,
          dateController: controller,
        );
        if (selectedDate != null) {
          setState(() {
            _selectedDateFilter = _formatDate(selectedDate);
            _currentPage = 0;
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: hasDate
              ? primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? DarkColors.surface : white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDate
                ? primary
                : (isDark ? DarkColors.border : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: 14,
              color: hasDate
                  ? primary
                  : (isDark ? DarkColors.textSecondary : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              hasDate ? _selectedDateFilter! : context.translate('date_due'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
                color: hasDate
                    ? primary
                    : (isDark ? DarkColors.textPrimary : Colors.grey[700]),
              ),
            ),
            if (hasDate) ...<Widget>[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = null;
                    _currentPage = 0;
                  });
                },
                child: const Icon(Icons.close, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Widget chip(final String label, final VoidCallback onDeleted) =>
        _buildFilterChip(
          context,
          isDark,
          label: label,
          onDeleted: () {
            setState(() {
              onDeleted();
              _currentPage = 0;
            });
          },
        );

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            'Active filters:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textSecondary : Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty)
            chip('Search: "$_searchQuery"', () => _searchQuery = emptyString),
          if (_selectedPaymentFilter != null)
            chip(
              'Payment: ${_paymentLabel(context, _selectedPaymentFilter!)}',
              () => _selectedPaymentFilter = null,
            ),
          if (_selectedStatusFilter != null)
            chip(
              'Status: ${_selectedStatusFilter! ? context.translate('active') : context.translate('inactive')}',
              () => _selectedStatusFilter = null,
            ),
          if (_selectedCategoryFilter != null)
            chip(
              'Category: ${_selectedCategoryFilter!.toTranslate(context)}',
              () => _selectedCategoryFilter = null,
            ),
          if (_selectedFrequencyFilter != null)
            chip(
              'Frequency: ${_selectedFrequencyFilter!.toTranslate(context)}',
              () => _selectedFrequencyFilter = null,
            ),
          if (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty)
            chip(
              'Date: $_selectedDateFilter',
              () => _selectedDateFilter = null,
            ),
          InkWell(
            onTap: () => _clearFilters(includeSearch: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              child: Text(
                'Reset all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    final BuildContext context,
    final bool isDark, {
    required final String label,
    required final VoidCallback onDeleted,
  }) {
    final Color primaryColor = isDark
        ? DarkColors.primary
        : LightColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.cancel, size: 14, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(
    final BuildContext context,
    final AccountToPayItem data,
  ) {
    final CustomPaymentFilters state = _paymentStateOf(data);
    final Color color;
    final IconData icon;
    switch (state) {
      case CustomPaymentFilters.paid:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case CustomPaymentFilters.overdue:
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case CustomPaymentFilters.pending:
        color = Colors.amber.shade800;
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            _paymentLabel(context, state),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AccountsToPayBloc, BaseState>(
      listener: (final BuildContext context, final BaseState state) {
        if (state is AccountsToPaySuccess) {
          setState(() {
            _items = state.items;
          });
        } else if (state is AccountsToPayError) {
          showSnackbar(context, state.error);
        }
      },
      child: Stack(
        children: <Widget>[
          CustomCardBody(
            isMain: false,
            isMenu: true,
            title: context.translate('accounts_to_pay'),
            description:
                'Track your bills and debts, and never miss a due date',
            buttonText: context.translate('add_account_to_pay'),
            buttonIsPrimary: true,
            buttonIsAdd: true,
            onButtonPressed: _addAccountToPay,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCards(context),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyContentWidget(
                          icon: Icons.receipt_long_outlined,
                          title: 'No accounts to pay registered yet',
                          subtitle:
                              'Keep your bills under control by adding your first account to pay.',
                          actionLabel: context.translate('add_account_to_pay'),
                          onAction: _addAccountToPay,
                        )
                      : Builder(
                          builder: (final BuildContext context) {
                            final List<AccountToPayItem> filtered =
                                _filteredItems;
                            final List<AccountToPayItem> paginated = filtered
                                .skip(_currentPage * _itemsPerPage)
                                .take(_itemsPerPage)
                                .toList();

                            return CustomDataTable<AccountToPayItem>(
                              data: paginated,
                              showToolbar: true,
                              isFiltered: _isFilterActive || _showFilterPanel,
                              filterPanel: _showFilterPanel
                                  ? _buildInlineFilterPanel(context)
                                  : null,
                              activeFilterChips:
                                  (_isFilterActive || _searchQuery.isNotEmpty)
                                  ? _buildActiveFilterChips(context)
                                  : null,
                              searchHint:
                                  'Search by creditor, category, or amount...',
                              onSearch: (final String query) {
                                setState(() {
                                  _searchQuery = query;
                                  _currentPage = 0;
                                });
                              },
                              onFilter: () {
                                setState(() {
                                  _showFilterPanel = !_showFilterPanel;
                                });
                              },
                              dataColumns: <String>[
                                context.translate('creditor_name'),
                                context.translate('category'),
                                context.translate('frequency'),
                                context.translate('description'),
                                context.translate('currency'),
                                context.translate('amount'),
                                context.translate('date_due'),
                                context.translate('payment_status'),
                                context.translate('status'),
                              ],
                              rowBuilder: (final AccountToPayItem data) {
                                return <Widget>[
                                  Text(
                                    data.creditorName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        data.category.icon,
                                        size: 16,
                                        color: isDark
                                            ? DarkColors.primary
                                            : LightColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          data.category.toTranslate(context),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(data.frequency.toTranslate(context)),
                                  Text(
                                    data.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(data.currency),
                                  Text(data.amount.toStringAsFixed(2)),
                                  Text(_formatDate(data.dueDate)),
                                  _buildPaymentStatusChip(context, data),
                                  CustomChipStatus(isActive: data.status),
                                ];
                              },
                              popupMenuBuilder: (final AccountToPayItem item) {
                                return PrimaryPopupMenu<CustomOptions>(
                                  popupItems: <PopupItem<CustomOptions>>[
                                    PopupItem<CustomOptions>(
                                      title: CustomOptions.edit.toTranslate(
                                        context,
                                      ),
                                      value: CustomOptions.edit,
                                    ),
                                    PopupItem<CustomOptions>(
                                      title: item.isPaid
                                          ? CustomOptions.markAsPending
                                                .toTranslate(context)
                                          : CustomOptions.markAsPaid
                                                .toTranslate(context),
                                      value: item.isPaid
                                          ? CustomOptions.markAsPending
                                          : CustomOptions.markAsPaid,
                                    ),
                                    PopupItem<CustomOptions>(
                                      title: CustomOptions.delete.toTranslate(
                                        context,
                                      ),
                                      value: CustomOptions.delete,
                                    ),
                                    PopupItem<CustomOptions>(
                                      title: item.status
                                          ? CustomOptions.deactivate
                                                .toTranslate(context)
                                          : CustomOptions.activate.toTranslate(
                                              context,
                                            ),
                                      value: item.status
                                          ? CustomOptions.deactivate
                                          : CustomOptions.activate,
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
                                            _editAccountToPay(item);
                                            break;
                                          case CustomOptions.markAsPaid:
                                            _togglePaidStatus(item, true);
                                            break;
                                          case CustomOptions.markAsPending:
                                            _togglePaidStatus(item, false);
                                            break;
                                          case CustomOptions.delete:
                                            _removeAccountToPay(item);
                                            break;
                                          case CustomOptions.activate:
                                            _setActive(item, true);
                                            break;
                                          case CustomOptions.deactivate:
                                            _setActive(item, false);
                                            break;
                                          default:
                                            break;
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              paginator: PaginationWidget(
                                currentPage: _currentPage,
                                totalItems: filtered.length,
                                itemsPerPage: _itemsPerPage,
                                onPageChanged: (final int newPage) {
                                  setState(() {
                                    _currentPage = newPage;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          BlocBuilder<AccountsToPayBloc, BaseState>(
            buildWhen: (final BaseState previous, final BaseState current) {
              return (previous is AccountsToPayInProgress) !=
                  (current is AccountsToPayInProgress);
            },
            builder: (final BuildContext context, final BaseState state) {
              if (state is AccountsToPayInProgress) {
                return const Loader();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(final BuildContext context) {
    final List<KpiCardSpec> specs =
        CurrencyKpiUtils.generateAccountToPayKpiCards(
          items: _items,
          user: _currentUser,
        );

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;
        const double maxCardWidth = 320.0;
        int crossAxisCount = 1;
        if (availableWidth > 1100) {
          crossAxisCount = 4;
        } else if (availableWidth > 700) {
          crossAxisCount = 2;
        }

        const double spacing = 16.0;
        double cardWidth =
            (availableWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        if (cardWidth > maxCardWidth && availableWidth > 360) {
          cardWidth = maxCardWidth;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: 12.0,
          children: specs.map((final KpiCardSpec spec) {
            return SizedBox(
              width: cardWidth,
              child: AccountToPayStatCard(
                title: spec.title,
                amount: spec.amount,
                subtitle: spec.subtitle,
                isPositive: spec.isPositive,
                icon: spec.icon,
                description: spec.description,
                calculation: spec.calculation,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<bool?> _showConfirmation(
    final BuildContext context,
    final String title,
    final String content,
  ) async {
    final Completer<bool?> completer = Completer<bool?>();
    CustomConfirmationDialog.showCustomConfirmationDialog(
      context,
      confirmationText: content,
      onPrimaryButtonTap: () {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onSecondaryButtonTap: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    ).then((_) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  void _openDrawer() {
    DrawerWidget.show(
      context: context,
      title: context.translate(
        _isEditing ? 'edit_account_to_pay' : 'add_account_to_pay',
      ),
      builder: (final BuildContext dialogContext) {
        return FormWidget(
          accountToPayItem: _editingItem,
          isEdit: _isEditing,
          onSave: (final AccountToPayItem item) {
            if (_isEditing) {
              _bloc.add(AccountsToPayUpdated(item: item));
            } else {
              _bloc.add(AccountsToPayAdded(item: item));
            }
            Navigator.of(dialogContext).pop();
            showSnackbar(
              context,
              context.translate('account_to_pay_saved_successfully'),
            );
          },
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _addAccountToPay() {
    _editingItem = null;
    _isEditing = false;
    _openDrawer();
  }

  void _editAccountToPay(final AccountToPayItem item) {
    _editingItem = item;
    _isEditing = true;
    _openDrawer();
  }

  void _togglePaidStatus(final AccountToPayItem item, final bool isPaid) {
    final AccountToPayItem updated = isPaid
        ? item.copyWith(isPaid: true, paymentDate: DateTime.now())
        : item.copyWith(isPaid: false, clearPaymentDate: true);
    _bloc.add(AccountsToPayUpdated(item: updated));
    showSnackbar(
      context,
      context.translate(
        isPaid ? 'account_to_pay_marked_paid' : 'account_to_pay_marked_pending',
      ),
    );
  }

  void _removeAccountToPay(final AccountToPayItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_account_to_pay_delete'),
    );
    if (confirmed == true) {
      _bloc.add(AccountsToPayDeleted(id: item.id, userId: item.userId));
      if (mounted) {
        showSnackbar(context, context.translate('account_to_pay_deleted'));
      }
    }
  }

  void _setActive(final AccountToPayItem item, final bool active) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate(active ? 'confirm_activation' : 'confirm_deactivation'),
      context.translate(
        active
            ? 'confirm_account_to_pay_activation'
            : 'confirm_account_to_pay_deactivation',
      ),
    );
    if (confirmed == true) {
      _bloc.add(AccountsToPayUpdated(item: item.copyWith(status: active)));
      if (mounted) {
        showSnackbar(
          context,
          context.translate(
            active ? 'account_to_pay_activated' : 'account_to_pay_deactivated',
          ),
        );
      }
    }
  }
}
