import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_status.dart';
import 'package:web_personal_finances/commons/chip/custom_chip_tag.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/drawer/drawer_widget.dart';
import 'package:web_personal_finances/commons/enum/custom_action_options.dart';
import 'package:web_personal_finances/commons/enum/custom_expense_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_expense_type_options.dart';
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
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/expenses/bloc/expenses_bloc.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'expense_stat_card.dart';
part 'expenses_form.dart';

class ExpensesBody extends StatefulWidget {
  const ExpensesBody({super.key});

  @override
  State<ExpensesBody> createState() => _ExpensesBodyState();
}

class _ExpensesBodyState extends State<ExpensesBody> {
  late ExpensesBloc _expensesBloc;
  List<ExpenseItem> _expenseItems = <ExpenseItem>[];

  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  ExpenseItem? _editingItem;
  bool _isEditing = false;

  UserModel? _currentUser;
  bool _showFilterPanel = false;
  String _searchQuery = emptyString;
  CustomExpenseTypeOptions? _selectedTypeFilter;
  CustomExpenseCategoryOptions? _selectedCategoryFilter;
  CustomFrequencyOptions? _selectedFrequencyFilter;
  bool? _selectedStatusFilter;
  String? _selectedDateFilter;

  List<ExpenseItem> get _filteredExpenses {
    return _expenseItems.where((final ExpenseItem item) {
      if (_searchQuery.isNotEmpty) {
        final String query = _searchQuery.toLowerCase().trim();
        final bool matchesName = item.name.toLowerCase().contains(query);
        final bool matchesComment = item.comment.toLowerCase().contains(query);
        final bool matchesCurrency = item.currency.toLowerCase().contains(
          query,
        );
        final bool matchesAmount = item.amount.toString().contains(query);
        final bool matchesFrequency = item.frequency
            .toTranslate(context)
            .toLowerCase()
            .contains(query);
        final bool matchesCategory = item.category
            .toTranslate(context)
            .toLowerCase()
            .contains(query);
        final bool matchesType =
            (item.isFixed
                    ? CustomExpenseTypeOptions.fixed
                    : CustomExpenseTypeOptions.variable)
                .toTranslate(context)
                .toLowerCase()
                .contains(query);
        final bool matchesDate = item.dateDue.toLowerCase().contains(query);
        final bool matchesTags = item.tags.any(
          (final String tag) => tag.toLowerCase().contains(query),
        );

        final String activeText = context.translate('active').toLowerCase();
        final String inactiveText = context.translate('inactive').toLowerCase();
        final bool matchesStatus =
            (item.status && activeText.contains(query)) ||
            (!item.status && inactiveText.contains(query));

        if (!matchesName &&
            !matchesComment &&
            !matchesCurrency &&
            !matchesAmount &&
            !matchesFrequency &&
            !matchesCategory &&
            !matchesType &&
            !matchesDate &&
            !matchesTags &&
            !matchesStatus) {
          return false;
        }
      }

      if (_selectedTypeFilter != null) {
        final bool isFixedFilter =
            _selectedTypeFilter == CustomExpenseTypeOptions.fixed;
        if (item.isFixed != isFixedFilter) {
          return false;
        }
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
          item.dateDue != _selectedDateFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  bool get _isFilterActive =>
      _selectedTypeFilter != null ||
      _selectedCategoryFilter != null ||
      _selectedFrequencyFilter != null ||
      _selectedStatusFilter != null ||
      (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _expensesBloc = context.read<ExpensesBloc>();
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    _expensesBloc.add(ExpensesFetched(userId: currentUid));
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expensesBloc = context.read<ExpensesBloc>();
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
          _buildStatusSegmentedControl(context, isDark),
          const SizedBox(width: 8.0),
          _buildTypeDropdown(context, isDark),
          const SizedBox(width: 8.0),
          _buildCategoryDropdown(context, isDark),
          const SizedBox(width: 8.0),
          _buildFrequencyDropdown(context, isDark),
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
              onPressed: () {
                setState(() {
                  _selectedTypeFilter = null;
                  _selectedCategoryFilter = null;
                  _selectedFrequencyFilter = null;
                  _selectedStatusFilter = null;
                  _selectedDateFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSegmentedControl(
    final BuildContext context,
    final bool isDark,
  ) {
    final String allLabel = context.translate('all');
    final String activeLabel = context.translate('active');
    final String inactiveLabel = context.translate('inactive');

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
            label: allLabel,
            isSelected: _selectedStatusFilter == null,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedStatusFilter = null;
                _currentPage = 0;
              });
            },
          ),
          _buildSegmentItem(
            label: activeLabel,
            isSelected: _selectedStatusFilter == true,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedStatusFilter = true;
                _currentPage = 0;
              });
            },
          ),
          _buildSegmentItem(
            label: inactiveLabel,
            isSelected: _selectedStatusFilter == false,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedStatusFilter = false;
                _currentPage = 0;
              });
            },
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

  Widget _buildTypeDropdown(final BuildContext context, final bool isDark) {
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
        child: DropdownButton<CustomExpenseTypeOptions?>(
          value: _selectedTypeFilter,
          hint: Text(
            context.translate('expense_type'),
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
          items: <DropdownMenuItem<CustomExpenseTypeOptions?>>[
            DropdownMenuItem<CustomExpenseTypeOptions?>(
              value: null,
              child: Text(
                '${context.translate('all')} ${context.translate('expense_type')}',
              ),
            ),
            ...CustomExpenseTypeOptions.values.map(
              (final CustomExpenseTypeOptions type) =>
                  DropdownMenuItem<CustomExpenseTypeOptions?>(
                    value: type,
                    child: Text(type.toTranslate(context)),
                  ),
            ),
          ],
          onChanged: (final CustomExpenseTypeOptions? val) {
            setState(() {
              _selectedTypeFilter = val;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(final BuildContext context, final bool isDark) {
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
        child: DropdownButton<CustomExpenseCategoryOptions?>(
          value: _selectedCategoryFilter,
          hint: Text(
            context.translate('category'),
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
          items: <DropdownMenuItem<CustomExpenseCategoryOptions?>>[
            DropdownMenuItem<CustomExpenseCategoryOptions?>(
              value: null,
              child: Text(
                '${context.translate('all')} ${context.translate('category')}',
              ),
            ),
            ...CustomExpenseCategoryOptions.values.map(
              (final CustomExpenseCategoryOptions cat) =>
                  DropdownMenuItem<CustomExpenseCategoryOptions?>(
                    value: cat,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          cat.icon,
                          size: 14,
                          color: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(cat.toTranslate(context)),
                      ],
                    ),
                  ),
            ),
          ],
          onChanged: (final CustomExpenseCategoryOptions? val) {
            setState(() {
              _selectedCategoryFilter = val;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown(
    final BuildContext context,
    final bool isDark,
  ) {
    final String allLabel = context.translate('all');
    final String currentVal = _selectedFrequencyFilter == null
        ? allLabel
        : _selectedFrequencyFilter!.toTranslate(context);

    final List<String> options = <String>[
      allLabel,
      ...CustomFrequencyOptions.values.map(
        (final CustomFrequencyOptions opt) => opt.toTranslate(context),
      ),
    ];

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
          dropdownColor: isDark ? DarkColors.surface : white,
          items: options.map((final String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (final String? newValue) {
            setState(() {
              if (newValue == null || newValue == allLabel) {
                _selectedFrequencyFilter = null;
              } else {
                _selectedFrequencyFilter = CustomFrequencyOptions.values
                    .firstWhere(
                      (final CustomFrequencyOptions opt) =>
                          opt.toTranslate(context) == newValue,
                    );
              }
              _currentPage = 0;
            });
          },
        ),
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
          final String formatted = DateFormat(
            dayMonthYearFormat,
          ).format(selectedDate);
          setState(() {
            _selectedDateFilter = formatted;
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
                    ? DarkColors.primary.withValues(alpha: 0.2)
                    : LightColors.primary.withValues(alpha: 0.1))
              : (isDark ? DarkColors.surface : white),
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
                  : (isDark ? DarkColors.textSecondary : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              hasDate ? _selectedDateFilter! : context.translate('date_due'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
                color: hasDate
                    ? (isDark ? DarkColors.primary : LightColors.primary)
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
    final String activeLabel = context.translate('active');
    final String inactiveLabel = context.translate('inactive');

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
            _buildFilterChip(
              context,
              isDark,
              label: 'Search: "$_searchQuery"',
              onDeleted: () {
                setState(() {
                  _searchQuery = emptyString;
                  _currentPage = 0;
                });
              },
            ),
          if (_selectedStatusFilter != null)
            _buildFilterChip(
              context,
              isDark,
              label:
                  'Status: ${_selectedStatusFilter! ? activeLabel : inactiveLabel}',
              onDeleted: () {
                setState(() {
                  _selectedStatusFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          if (_selectedTypeFilter != null)
            _buildFilterChip(
              context,
              isDark,
              label: 'Type: ${_selectedTypeFilter!.toTranslate(context)}',
              onDeleted: () {
                setState(() {
                  _selectedTypeFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          if (_selectedCategoryFilter != null)
            _buildFilterChip(
              context,
              isDark,
              label:
                  'Category: ${_selectedCategoryFilter!.toTranslate(context)}',
              onDeleted: () {
                setState(() {
                  _selectedCategoryFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          if (_selectedFrequencyFilter != null)
            _buildFilterChip(
              context,
              isDark,
              label:
                  'Frequency: ${_selectedFrequencyFilter!.toTranslate(context)}',
              onDeleted: () {
                setState(() {
                  _selectedFrequencyFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          if (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty)
            _buildFilterChip(
              context,
              isDark,
              label: 'Date: $_selectedDateFilter',
              onDeleted: () {
                setState(() {
                  _selectedDateFilter = null;
                  _currentPage = 0;
                });
              },
            ),
          InkWell(
            onTap: () {
              setState(() {
                _searchQuery = emptyString;
                _selectedTypeFilter = null;
                _selectedCategoryFilter = null;
                _selectedFrequencyFilter = null;
                _selectedStatusFilter = null;
                _selectedDateFilter = null;
                _currentPage = 0;
              });
            },
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

  @override
  Widget build(final BuildContext context) {
    return BlocListener<ExpensesBloc, BaseState>(
      listener: (final BuildContext context, final BaseState state) {
        if (state is ExpensesSuccess) {
          setState(() {
            _expenseItems = state.expenses;
          });
        }
      },
      child: Stack(
        children: <Widget>[
          CustomCardBody(
            isMain: false,
            isMenu: true,
            title: context.translate('expenses'),
            description:
                'Track and analyze fixed and variable outgoing expenses',
            buttonText: context.translate('add_expense'),
            buttonIsPrimary: true,
            buttonIsAdd: true,
            onButtonPressed: _addExpense,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCards(context),
                Expanded(
                  child: _expenseItems.isEmpty
                      ? EmptyContentWidget(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No expenses registered yet',
                          subtitle:
                              'Start tracking your budget by adding your first expense entry.',
                          actionLabel: context.translate('add_expense'),
                          onAction: _addExpense,
                        )
                      : Builder(
                          builder: (final BuildContext context) {
                            final List<ExpenseItem> filtered =
                                _filteredExpenses;
                            final List<ExpenseItem> paginatedExpenses = filtered
                                .skip(_currentPage * _itemsPerPage)
                                .take(_itemsPerPage)
                                .toList();

                            return CustomDataTable<ExpenseItem>(
                              data: paginatedExpenses,
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
                                  'Search by name, category, or amount...',
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
                                context.translate('name'),
                                context.translate('expense_type'),
                                context.translate('category'),
                                context.translate('frequency'),
                                context.translate('comment'),
                                context.translate('currency'),
                                context.translate('amount'),
                                context.translate('date_due'),
                                context.translate('payment_status'),
                                context.translate('status'),
                              ],
                              rowBuilder: (final ExpenseItem data) {
                                final bool isDark =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                final CustomExpenseTypeOptions typeOpt =
                                    data.isFixed
                                    ? CustomExpenseTypeOptions.fixed
                                    : CustomExpenseTypeOptions.variable;

                                return <Widget>[
                                  Text(
                                    data.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data.isFixed
                                          ? Colors.blue.withValues(alpha: 0.12)
                                          : Colors.orange.withValues(
                                              alpha: 0.12,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: data.isFixed
                                            ? Colors.blue.withValues(alpha: 0.4)
                                            : Colors.orange.withValues(
                                                alpha: 0.4,
                                              ),
                                      ),
                                    ),
                                    child: Text(
                                      typeOpt.toTranslate(context),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: data.isFixed
                                            ? Colors.blue.shade700
                                            : Colors.orange.shade800,
                                      ),
                                    ),
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
                                    data.comment,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(data.currency),
                                  Text(data.amount.toStringAsFixed(2)),
                                  Text(data.dateDue),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data.isPaid
                                          ? Colors.green.withValues(alpha: 0.12)
                                          : Colors.amber.withValues(
                                              alpha: 0.12,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: data.isPaid
                                            ? Colors.green.withValues(
                                                alpha: 0.5,
                                              )
                                            : Colors.amber.withValues(
                                                alpha: 0.5,
                                              ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          data.isPaid
                                              ? Icons.check_circle_outline
                                              : Icons.schedule,
                                          size: 13,
                                          color: data.isPaid
                                              ? Colors.green
                                              : Colors.amber.shade800,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          data.isPaid
                                              ? context.translate('paid')
                                              : context.translate('pending'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: data.isPaid
                                                ? Colors.green
                                                : Colors.amber.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomChipStatus(isActive: data.status),
                                ];
                              },
                              popupMenuBuilder: (final ExpenseItem item) {
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
                                    if (!item.status)
                                      PopupItem<CustomOptions>(
                                        title: CustomOptions.activate
                                            .toTranslate(context),
                                        value: CustomOptions.activate,
                                      ),
                                    if (item.status)
                                      PopupItem<CustomOptions>(
                                        title: CustomOptions.deactivate
                                            .toTranslate(context),
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
                                            _editExpense(item);
                                            break;
                                          case CustomOptions.markAsPaid:
                                            _togglePaidStatus(item, true);
                                            break;
                                          case CustomOptions.markAsPending:
                                            _togglePaidStatus(item, false);
                                            break;
                                          case CustomOptions.delete:
                                            _removeExpense(item);
                                            break;
                                          case CustomOptions.activate:
                                            _activateExpense(item);
                                            break;
                                          case CustomOptions.deactivate:
                                            _deactivateExpense(item);
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
          BlocBuilder<ExpensesBloc, BaseState>(
            buildWhen: (final BaseState previous, final BaseState current) {
              return (previous is ExpensesInProgress) !=
                  (current is ExpensesInProgress);
            },
            builder: (final BuildContext context, final BaseState state) {
              if (state is ExpensesInProgress) {
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
      title: context.translate(_isEditing ? 'edit_expense' : 'add_expense'),
      builder: (final BuildContext dialogContext) {
        return FormWidget(
          expenseItem: _editingItem,
          isEdit: _isEditing,
          onSave: (final ExpenseItem item) {
            if (_isEditing) {
              _expensesBloc.add(ExpensesUpdated(expenseItem: item));
            } else {
              _expensesBloc.add(ExpensesAdded(expenseItem: item));
            }
            Navigator.of(dialogContext).pop();
            showSnackbar(
              context,
              context.translate('expense_saved_successfully'),
            );
          },
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _addExpense() {
    _editingItem = null;
    _isEditing = false;
    _openDrawer();
  }

  void _editExpense(final ExpenseItem item) {
    _editingItem = item;
    _isEditing = true;
    _openDrawer();
  }

  void _togglePaidStatus(final ExpenseItem item, final bool isPaid) {
    final ExpenseItem updated = ExpenseItem(
      id: item.id,
      userId: item.userId,
      name: item.name,
      comment: item.comment,
      currency: item.currency,
      amount: item.amount,
      dateDue: item.dateDue,
      status: item.status,
      isPaid: isPaid,
      isFixed: item.isFixed,
      category: item.category,
      frequency: item.frequency,
      createdDate: item.createdDate,
      tags: item.tags,
      paymentMethod: item.paymentMethod,
    );
    _expensesBloc.add(ExpensesUpdated(expenseItem: updated));
    showSnackbar(
      context,
      isPaid
          ? context.translate('expense_marked_paid')
          : context.translate('expense_marked_pending'),
    );
  }

  void _removeExpense(final ExpenseItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_expense_delete'),
    );
    if (confirmed == true) {
      _expensesBloc.add(ExpensesDeleted(id: item.id, userId: item.userId));
      showSnackbar(context, context.translate('expense_deleted'));
    }
  }

  void _activateExpense(final ExpenseItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_activation'),
      context.translate('confirm_expense_activation'),
    );
    if (confirmed == true) {
      final ExpenseItem updated = ExpenseItem(
        id: item.id,
        userId: item.userId,
        name: item.name,
        comment: item.comment,
        currency: item.currency,
        amount: item.amount,
        dateDue: item.dateDue,
        status: true,
        isPaid: item.isPaid,
        isFixed: item.isFixed,
        category: item.category,
        frequency: item.frequency,
        createdDate: item.createdDate,
        tags: item.tags,
        paymentMethod: item.paymentMethod,
      );
      _expensesBloc.add(ExpensesUpdated(expenseItem: updated));
      showSnackbar(context, context.translate('expense_activated'));
    }
  }

  void _deactivateExpense(final ExpenseItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_deactivation'),
      context.translate('confirm_expense_deactivation'),
    );
    if (confirmed == true) {
      final ExpenseItem updated = ExpenseItem(
        id: item.id,
        userId: item.userId,
        name: item.name,
        comment: item.comment,
        currency: item.currency,
        amount: item.amount,
        dateDue: item.dateDue,
        status: false,
        isPaid: item.isPaid,
        isFixed: item.isFixed,
        category: item.category,
        frequency: item.frequency,
        createdDate: item.createdDate,
        tags: item.tags,
        paymentMethod: item.paymentMethod,
      );
      _expensesBloc.add(ExpensesUpdated(expenseItem: updated));
      showSnackbar(context, context.translate('expense_deactivated'));
    }
  }

  Widget _buildStatCards(final BuildContext context) {
    final List<KpiCardSpec> specs = CurrencyKpiUtils.generateExpenseKpiCards(
      expenseItems: _expenseItems,
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
              child: ExpenseStatCard(
                title: spec.title,
                amount: spec.amount,
                subtitle: spec.subtitle,
                changePercent: spec.changePercent,
                isPositive: spec.isPositive,
                icon: spec.icon,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
