import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/bloc/accounts_receivable_bloc.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_payment.dart';
import 'package:web_personal_finances/accountsReceivable/widget/amortization_schedule_dialog.dart';
import 'package:web_personal_finances/accountsReceivable/widget/payment_history_dialog.dart';
import 'package:web_personal_finances/accountsReceivable/widget/record_payment_dialog.dart';
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
import 'package:web_personal_finances/commons/enum/custom_account_receivable_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_interest_type.dart';
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
import 'package:web_personal_finances/commons/utils/account_receivable_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/decimal_input_formatter.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'account_receivable_stat_card.dart';
part 'accounts_receivable_form.dart';

class AccountsReceivableBody extends StatefulWidget {
  const AccountsReceivableBody({super.key});

  @override
  State<AccountsReceivableBody> createState() => _AccountsReceivableBodyState();
}

class _AccountsReceivableBodyState extends State<AccountsReceivableBody> {
  late AccountsReceivableBloc _bloc;
  List<AccountReceivableItem> _items = <AccountReceivableItem>[];

  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  AccountReceivableItem? _editingItem;
  bool _isEditing = false;

  UserModel? _currentUser;
  bool _showFilterPanel = false;
  String _searchQuery = emptyString;
  CustomPaymentFilters? _selectedPaymentFilter;
  CustomAccountReceivableCategoryOptions? _selectedCategoryFilter;
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
      case CustomPaymentFilters.partiallyPaid:
        return context.translate('partially_paid');
      case CustomPaymentFilters.paid:
        return context.translate('received');
    }
  }

  CustomPaymentFilters _paymentStateOf(final AccountReceivableItem item) =>
      AccountReceivableUtils.getPaymentState(item);

  List<AccountReceivableItem> get _filteredItems {
    return _items.where((final AccountReceivableItem item) {
      if (_searchQuery.isNotEmpty) {
        final String query = _searchQuery.toLowerCase().trim();
        final String activeText = context.translate('active').toLowerCase();
        final String inactiveText = context.translate('inactive').toLowerCase();
        final bool matches =
            item.debtorName.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.currency.toLowerCase().contains(query) ||
            item.amount.toString().contains(query) ||
            item.remainingBalance.toString().contains(query) ||
            item.frequency.toTranslate(context).toLowerCase().contains(query) ||
            item.category.toTranslate(context).toLowerCase().contains(query) ||
            _formatDate(
              AccountReceivableUtils.getNextDueDate(item),
            ).contains(query) ||
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
          _formatDate(AccountReceivableUtils.getNextDueDate(item)) !=
              _selectedDateFilter &&
          _formatDate(item.dueDate) != _selectedDateFilter) {
        return false;
      }
      return true;
    }).toList()..sort(
      (final AccountReceivableItem a, final AccountReceivableItem b) =>
          AccountReceivableUtils.getNextDueDate(
            a,
          ).compareTo(AccountReceivableUtils.getNextDueDate(b)),
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
    _bloc = context.read<AccountsReceivableBloc>();
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    _bloc.add(AccountsReceivableFetched(userId: currentUid));
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<AccountsReceivableBloc>();
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
          _buildFilterDropdown<CustomAccountReceivableCategoryOptions?>(
            isDark: isDark,
            hint: context.translate('category'),
            value: _selectedCategoryFilter,
            allLabel:
                '${context.translate('all')} ${context.translate('category')}',
            options: <CustomAccountReceivableCategoryOptions?, String>{
              for (final CustomAccountReceivableCategoryOptions cat
                  in CustomAccountReceivableCategoryOptions.values)
                cat: cat.toTranslate(context),
            },
            onChanged: (final CustomAccountReceivableCategoryOptions? val) =>
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
              for (final CustomFrequencyOptions freq
                  in CustomFrequencyOptions.values)
                freq: freq.toTranslate(context),
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
    required final T value,
    required final String allLabel,
    required final Map<T, String> options,
    required final void Function(T) onChanged,
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
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? DarkColors.textSecondary : greyHard,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isDark ? DarkColors.textSecondary : greyHard,
          ),
          items: <DropdownMenuItem<T>>[
            DropdownMenuItem<T>(
              value: null as T,
              child: Text(
                allLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? white : LightColors.textPrimary,
                ),
              ),
            ),
            ...options.entries.map(
              (final MapEntry<T, String> e) => DropdownMenuItem<T>(
                value: e.key,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
          onChanged: (final T? val) {
            setState(() {
              onChanged(val as T);
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
    final List<CustomPaymentFilters?> filters = <CustomPaymentFilters?>[
      null,
      CustomPaymentFilters.pending,
      CustomPaymentFilters.partiallyPaid,
      CustomPaymentFilters.overdue,
      CustomPaymentFilters.paid,
    ];

    String labelFor(final CustomPaymentFilters? f) {
      if (f == null) return context.translate('all');
      return _paymentLabel(context, f);
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((final CustomPaymentFilters? filter) {
          final bool isSelected = _selectedPaymentFilter == filter;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedPaymentFilter = filter;
                _currentPage = 0;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? DarkColors.primary : LightColors.primary)
                    : transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labelFor(filter),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? white
                      : (isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePickerButton(final BuildContext context, final bool isDark) {
    final bool hasDate =
        _selectedDateFilter != null && _selectedDateFilter!.isNotEmpty;
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
              ? (isDark
                    ? DarkColors.primary.withValues(alpha: 0.15)
                    : LightColors.primary.withValues(alpha: 0.1))
              : (isDark ? DarkColors.surface : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDate
                ? (isDark ? DarkColors.primary : LightColors.primary)
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
                  ? (isDark ? DarkColors.primary : LightColors.primary)
                  : (isDark ? DarkColors.textSecondary : greyHard),
            ),
            const SizedBox(width: 6),
            Text(
              hasDate ? _selectedDateFilter! : context.translate('date_due'),
              style: TextStyle(
                fontSize: 12,
                color: hasDate
                    ? (isDark ? DarkColors.primary : LightColors.primary)
                    : (isDark ? DarkColors.textSecondary : greyHard),
                fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasDate) ...<Widget>[
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = null;
                    _currentPage = 0;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark ? DarkColors.primary : LightColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(
        _buildFilterBadge(
          context,
          label: '"$_searchQuery"',
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _searchQuery = emptyString;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (_selectedPaymentFilter != null) {
      chips.add(
        _buildFilterBadge(
          context,
          label: _paymentLabel(context, _selectedPaymentFilter!),
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedPaymentFilter = null;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (_selectedStatusFilter != null) {
      chips.add(
        _buildFilterBadge(
          context,
          label: _selectedStatusFilter!
              ? context.translate('active')
              : context.translate('inactive'),
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedStatusFilter = null;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (_selectedCategoryFilter != null) {
      chips.add(
        _buildFilterBadge(
          context,
          label: _selectedCategoryFilter!.toTranslate(context),
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedCategoryFilter = null;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (_selectedFrequencyFilter != null) {
      chips.add(
        _buildFilterBadge(
          context,
          label: _selectedFrequencyFilter!.toTranslate(context),
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedFrequencyFilter = null;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty) {
      chips.add(
        _buildFilterBadge(
          context,
          label: _selectedDateFilter!,
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedDateFilter = null;
              _currentPage = 0;
            });
          },
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 4.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ...chips,
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _clearFilters(includeSearch: true),
            child: Text(
              context.translate('clear_filters'),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? DarkColors.primary : LightColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(
    final BuildContext context, {
    required final String label,
    required final bool isDark,
    required final VoidCallback onDeleted,
  }) {
    final Color primaryColor = isDark
        ? DarkColors.primary
        : LightColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 4),
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
    final AccountReceivableItem data,
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
      case CustomPaymentFilters.partiallyPaid:
        color = Colors.blue.shade700;
        icon = Icons.pie_chart_outline_rounded;
        break;
      case CustomPaymentFilters.pending:
        color = Colors.amber.shade800;
        icon = Icons.schedule;
        break;
    }

    final String label = _paymentLabel(context, state);

    return Tooltip(
      message: label,
      child: Container(
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
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueSoonBadge(
    final BuildContext context, {
    required final int daysLeft,
    required final bool isDark,
  }) {
    final String label;
    if (daysLeft == 0) {
      label = context.translate('due_today');
    } else if (daysLeft == 1) {
      label = context.translate('due_tomorrow');
    } else {
      label = context.translate(
        'due_in_days',
        namedArgs: <String, String>{'days': '$daysLeft'},
      );
    }

    final Color badgeColor = daysLeft == 0
        ? Colors.red.shade700
        : Colors.deepOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.alarm, size: 10, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniQuotaProgress(
    final BuildContext context,
    final AccountReceivableItem data, {
    required final bool isDark,
  }) {
    final int total = data.totalQuotas ?? 0;
    if (total <= 0) {
      return const SizedBox.shrink();
    }
    final int paid = LoanAmortizationUtils.getPaidReceivableQuotasCount(data);
    final double percent = (paid / total).clamp(0.0, 1.0);
    final Color progressColor = percent >= 1.0
        ? Colors.green
        : (isDark ? DarkColors.primary : LightColors.primary);
    final Color trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final String tooltipText = context.translate(
      'quotas_progress_tooltip',
      namedArgs: <String, String>{
        'paid': '$paid',
        'total': '$total',
        'percent': (percent * 100).toStringAsFixed(0),
      },
    );

    return Tooltip(
      message: tooltipText,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$paid/$total',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AccountsReceivableBloc, BaseState>(
      listener: (final BuildContext context, final BaseState state) {
        if (state is AccountsReceivableSuccess) {
          setState(() {
            _items = state.items;
          });
        } else if (state is AccountsReceivableError) {
          showSnackbar(context, state.error);
        }
      },
      child: Stack(
        children: <Widget>[
          CustomCardBody(
            isMain: false,
            isMenu: true,
            title: context.translate('accounts_receivable'),
            description:
                'Track money owed to you and manage scheduled collections',
            buttonText: context.translate('add_account_receivable'),
            buttonIsPrimary: true,
            buttonIsAdd: true,
            onButtonPressed: _addAccountReceivable,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCards(context),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyContentWidget(
                          icon: Icons.request_quote_outlined,
                          title: 'No accounts receivable registered yet',
                          subtitle:
                              'Stay in control of what clients or debtors owe you by registering your first receivable.',
                          actionLabel: context.translate(
                            'add_account_receivable',
                          ),
                          onAction: _addAccountReceivable,
                        )
                      : Builder(
                          builder: (final BuildContext context) {
                            final List<AccountReceivableItem> filtered =
                                _filteredItems;
                            final List<AccountReceivableItem> paginated =
                                filtered
                                    .skip(_currentPage * _itemsPerPage)
                                    .take(_itemsPerPage)
                                    .toList();

                            return CustomDataTable<AccountReceivableItem>(
                              data: paginated,
                              showToolbar: true,
                              minWidth: 1080.0,
                              cellPadding: const EdgeInsets.only(left: 14.0),
                              columnFlexes: const <int>[
                                14, // Debtor Name
                                12, // Category
                                8, // Frequency
                                14, // Description
                                7, // Currency
                                9, // Amount
                                10, // Remaining Balance
                                9, // Due Date
                                14, // Payment Status Chip
                                9, // Status (Active/Inactive)
                              ],
                              isFiltered: _isFilterActive || _showFilterPanel,
                              filterPanel: _showFilterPanel
                                  ? _buildInlineFilterPanel(context)
                                  : null,
                              activeFilterChips:
                                  (_isFilterActive || _searchQuery.isNotEmpty)
                                  ? _buildActiveFilterChips(context)
                                  : null,
                              searchHint:
                                  'Search by debtor, category, or amount...',
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
                                context.translate('debtor_name'),
                                context.translate('category'),
                                context.translate('frequency'),
                                context.translate('description'),
                                context.translate('currency'),
                                context.translate('amount'),
                                context.translate('remaining_balance'),
                                context.translate('date_due'),
                                context.translate('payment_status'),
                                context.translate('status'),
                              ],
                              rowBuilder: (final AccountReceivableItem data) {
                                return <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        data.debtorName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (data.isLoanAccount &&
                                          (data.totalQuotas ?? 0) >
                                              0) ...<Widget>[
                                        const SizedBox(height: 3),
                                        _buildMiniQuotaProgress(
                                          context,
                                          data,
                                          isDark: isDark,
                                        ),
                                      ],
                                    ],
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
                                  Text(
                                    data.remainingBalance.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: data.isFullyPaid
                                          ? Colors.green
                                          : (AccountReceivableUtils.isOverdue(
                                                  data,
                                                )
                                                ? Colors.red
                                                : (data.isPartiallyPaid
                                                      ? Colors.blue.shade700
                                                      : null)),
                                    ),
                                  ),
                                  Builder(
                                    builder: (final BuildContext ctx) {
                                      final bool isDueSoon =
                                          AccountReceivableUtils.isDueSoon(
                                            data,
                                          );
                                      final int daysLeft =
                                          AccountReceivableUtils.daysUntilDue(
                                            data,
                                          );
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            _formatDate(
                                              AccountReceivableUtils.getNextDueDate(
                                                data,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontWeight: isDueSoon
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: isDueSoon
                                                  ? Colors.deepOrange.shade800
                                                  : null,
                                            ),
                                          ),
                                          if (isDueSoon) ...<Widget>[
                                            const SizedBox(height: 3),
                                            _buildDueSoonBadge(
                                              context,
                                              daysLeft: daysLeft,
                                              isDark: isDark,
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                  _buildPaymentStatusChip(context, data),
                                  CustomChipStatus(isActive: data.status),
                                ];
                              },
                              popupMenuBuilder:
                                  (final AccountReceivableItem item) {
                                    return PrimaryPopupMenu<CustomOptions>(
                                      popupItems: <PopupItem<CustomOptions>>[
                                        PopupItem<CustomOptions>(
                                          title: CustomOptions.edit.toTranslate(
                                            context,
                                          ),
                                          value: CustomOptions.edit,
                                        ),
                                        if (!item.isFullyPaid)
                                          PopupItem<CustomOptions>(
                                            title: CustomOptions.recordPayment
                                                .toTranslate(context),
                                            value: CustomOptions.recordPayment,
                                          ),
                                        if (item.isLoanAccount)
                                          PopupItem<CustomOptions>(
                                            title: CustomOptions
                                                .amortizationSchedule
                                                .toTranslate(context),
                                            value: CustomOptions
                                                .amortizationSchedule,
                                          ),
                                        if (item.payments.isNotEmpty)
                                          PopupItem<CustomOptions>(
                                            title: CustomOptions
                                                .collectionHistory
                                                .toTranslate(context),
                                            value:
                                                CustomOptions.collectionHistory,
                                          ),
                                        PopupItem<CustomOptions>(
                                          title: item.isFullyPaid
                                              ? CustomOptions.markAsPending
                                                    .toTranslate(context)
                                              : CustomOptions.markAsReceived
                                                    .toTranslate(context),
                                          value: item.isFullyPaid
                                              ? CustomOptions.markAsPending
                                              : CustomOptions.markAsReceived,
                                        ),
                                        PopupItem<CustomOptions>(
                                          title: CustomOptions.delete
                                              .toTranslate(context),
                                          value: CustomOptions.delete,
                                        ),
                                        PopupItem<CustomOptions>(
                                          title: item.status
                                              ? CustomOptions.deactivate
                                                    .toTranslate(context)
                                              : CustomOptions.activate
                                                    .toTranslate(context),
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
                                                _editAccountReceivable(item);
                                                break;
                                              case CustomOptions.recordPayment:
                                                _recordPayment(item);
                                                break;
                                              case CustomOptions
                                                  .amortizationSchedule:
                                                _viewAmortizationSchedule(item);
                                                break;
                                              case CustomOptions
                                                  .collectionHistory:
                                                _viewCollectionHistory(item);
                                                break;
                                              case CustomOptions.markAsReceived:
                                                _toggleReceivedStatus(
                                                  item,
                                                  true,
                                                );
                                                break;
                                              case CustomOptions.markAsPending:
                                                _toggleReceivedStatus(
                                                  item,
                                                  false,
                                                );
                                                break;
                                              case CustomOptions.delete:
                                                _removeAccountReceivable(item);
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
          BlocBuilder<AccountsReceivableBloc, BaseState>(
            buildWhen: (final BaseState previous, final BaseState current) {
              return (previous is AccountsReceivableInProgress) !=
                  (current is AccountsReceivableInProgress);
            },
            builder: (final BuildContext context, final BaseState state) {
              if (state is AccountsReceivableInProgress) {
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
        CurrencyKpiUtils.generateAccountReceivableKpiCards(
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
              child: AccountReceivableStatCard(
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
        _isEditing ? 'edit_account_receivable' : 'add_account_receivable',
      ),
      builder: (final BuildContext dialogContext) {
        return FormWidget(
          accountReceivableItem: _editingItem,
          isEdit: _isEditing,
          onSave: (final AccountReceivableItem item) {
            if (_isEditing) {
              _bloc.add(AccountsReceivableUpdated(item: item));
            } else {
              _bloc.add(AccountsReceivableAdded(item: item));
            }
            Navigator.of(dialogContext).pop();
            showSnackbar(
              context,
              context.translate('account_receivable_saved_successfully'),
            );
          },
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _addAccountReceivable() {
    _editingItem = null;
    _isEditing = false;
    _openDrawer();
  }

  void _editAccountReceivable(final AccountReceivableItem item) {
    _editingItem = item;
    _isEditing = true;
    _openDrawer();
  }

  void _recordPayment(final AccountReceivableItem item) {
    RecordPaymentDialog.show(
      context: context,
      item: item,
      onPaymentRecorded: (final AccountReceivableItem updated) {
        _bloc.add(AccountsReceivableUpdated(item: updated));
        showSnackbar(
          context,
          context.translate('payment_recorded_successfully'),
        );
      },
    );
  }

  void _viewAmortizationSchedule(final AccountReceivableItem item) {
    AmortizationScheduleDialog.show(
      context: context,
      item: item,
      onPaymentRecorded: (final AccountReceivableItem updated) {
        _bloc.add(AccountsReceivableUpdated(item: updated));
        showSnackbar(
          context,
          context.translate('payment_recorded_successfully'),
        );
      },
    );
  }

  void _viewCollectionHistory(final AccountReceivableItem item) {
    PaymentHistoryDialog.show(
      context: context,
      item: item,
      onPaymentRemoved: (final AccountReceivableItem updated) {
        _bloc.add(AccountsReceivableUpdated(item: updated));
        showSnackbar(
          context,
          context.translate('payment_deleted_successfully'),
        );
      },
    );
  }

  void _toggleReceivedStatus(
    final AccountReceivableItem item,
    final bool isReceived,
  ) {
    final AccountReceivableItem updated = item.copyWith(
      isReceived: isReceived,
      paymentDate: isReceived ? (item.paymentDate ?? DateTime.now()) : null,
      clearPaymentDate: !isReceived,
    );
    _bloc.add(AccountsReceivableUpdated(item: updated));
    showSnackbar(
      context,
      isReceived
          ? context.translate('account_receivable_marked_received')
          : context.translate('account_receivable_marked_pending'),
    );
  }

  void _removeAccountReceivable(final AccountReceivableItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_account_receivable_delete'),
    );
    if (confirmed == true) {
      _bloc.add(AccountsReceivableDeleted(id: item.id, userId: item.userId));
      showSnackbar(context, context.translate('account_receivable_deleted'));
    }
  }

  void _setActive(final AccountReceivableItem item, final bool active) async {
    final bool? confirmed = await _showConfirmation(
      context,
      active
          ? context.translate('confirm_activation')
          : context.translate('confirm_deactivation'),
      active
          ? context.translate('confirm_account_receivable_activation')
          : context.translate('confirm_account_receivable_deactivation'),
    );
    if (confirmed == true) {
      final AccountReceivableItem updated = item.copyWith(status: active);
      _bloc.add(AccountsReceivableUpdated(item: updated));
      showSnackbar(
        context,
        active
            ? context.translate('account_receivable_activated')
            : context.translate('account_receivable_deactivated'),
      );
    }
  }
}
