import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
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
import 'package:web_personal_finances/commons/enum/custom_saving_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
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
import 'package:web_personal_finances/commons/utils/saving_utils.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/bloc/savings_bloc.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';
import 'package:web_personal_finances/savings/widget/record_transaction_dialog.dart';
import 'package:web_personal_finances/savings/widget/saving_history_dialog.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'savings_form.dart';
part 'saving_stat_card.dart';

class SavingsBody extends StatefulWidget {
  const SavingsBody({super.key});

  @override
  State<SavingsBody> createState() => _SavingsBodyState();
}

class _SavingsBodyState extends State<SavingsBody> {
  late SavingsBloc _bloc;
  List<SavingItem> _items = <SavingItem>[];

  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  SavingItem? _editingItem;
  bool _isEditing = false;

  UserModel? _currentUser;
  bool _showFilterPanel = false;
  String _searchQuery = emptyString;
  CustomSavingCategoryOptions? _selectedCategoryFilter;
  bool? _selectedStatusFilter;
  String? _selectedCompletionFilter; // 'all', 'in_progress', 'completed'

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SavingsBloc>();
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;
    _bloc.add(SavingsFetched(userId: currentUid));
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    UserModel? user;
    try {
      user = context.read<AppAuthNotifier>().userProfile;
    } catch (_) {}

    if (user == null) {
      try {
        final UserRepository userRepository = context.read<UserRepository>();
        user = await userRepository.getUser(authUser.uid);
      } catch (_) {}
    }

    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  String _formatDate(final DateTime? date) {
    if (date == null) return context.translate('no_target_date');
    return DateFormat(dayMonthYearFormat).format(date);
  }

  bool get _isFilterActive =>
      _selectedCategoryFilter != null ||
      _selectedStatusFilter != null ||
      (_selectedCompletionFilter != null && _selectedCompletionFilter != 'all');

  void _clearFilters({final bool includeSearch = false}) {
    setState(() {
      if (includeSearch) {
        _searchQuery = emptyString;
      }
      _selectedCategoryFilter = null;
      _selectedStatusFilter = null;
      _selectedCompletionFilter = null;
      _currentPage = 0;
    });
  }

  List<SavingItem> get _filteredItems {
    return _items.where((final SavingItem item) {
      if (_searchQuery.isNotEmpty) {
        final String query = _searchQuery.toLowerCase().trim();
        final bool matches =
            item.name.toLowerCase().contains(query) ||
            item.comment.toLowerCase().contains(query) ||
            item.currency.toLowerCase().contains(query) ||
            item.category.toTranslate(context).toLowerCase().contains(query) ||
            item.currentAmount.toString().contains(query) ||
            item.goalAmount.toString().contains(query) ||
            _formatDate(item.targetDate).toLowerCase().contains(query) ||
            item.tags.any((final String t) => t.toLowerCase().contains(query));
        if (!matches) return false;
      }

      if (_selectedCategoryFilter != null &&
          item.category != _selectedCategoryFilter) {
        return false;
      }

      if (_selectedStatusFilter != null &&
          item.status != _selectedStatusFilter) {
        return false;
      }

      if (_selectedCompletionFilter != null &&
          _selectedCompletionFilter != 'all') {
        if (_selectedCompletionFilter == 'completed' && !item.isCompleted) {
          return false;
        }
        if (_selectedCompletionFilter == 'in_progress' && item.isCompleted) {
          return false;
        }
      }

      return true;
    }).toList();
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

  Widget _buildCompletionSegmentedControl(
    final BuildContext context,
    final bool isDark,
  ) {
    final List<String?> filters = <String?>[null, 'in_progress', 'completed'];

    String labelFor(final String? f) {
      if (f == null) return context.translate('all');
      if (f == 'completed') return context.translate('goal_reached');
      return context.translate('in_progress');
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
        children: filters.map((final String? filter) {
          final bool isSelected =
              (_selectedCompletionFilter == null && filter == null) ||
              (_selectedCompletionFilter == filter);
          return InkWell(
            onTap: () {
              setState(() {
                _selectedCompletionFilter = filter;
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

  Widget _buildInlineFilterPanel(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildCompletionSegmentedControl(context, isDark),
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
          _buildFilterDropdown<CustomSavingCategoryOptions?>(
            isDark: isDark,
            hint: context.translate('category'),
            value: _selectedCategoryFilter,
            allLabel:
                '${context.translate('all')} ${context.translate('category')}',
            options: <CustomSavingCategoryOptions?, String>{
              for (final CustomSavingCategoryOptions cat
                  in CustomSavingCategoryOptions.values)
                cat: cat.toTranslate(context),
            },
            onChanged: (final CustomSavingCategoryOptions? val) =>
                _selectedCategoryFilter = val,
          ),
          if (_isFilterActive) ...<Widget>[
            const SizedBox(width: 4.0),
            IconButton(
              tooltip: context.translate('clear_filters'),
              icon: Icon(
                Icons.clear_all,
                size: 20,
                color: isDark ? DarkColors.primary : LightColors.primary,
              ),
              onPressed: () => _clearFilters(),
            ),
          ],
        ],
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

    if (_selectedCompletionFilter != null &&
        _selectedCompletionFilter != 'all') {
      final String label = _selectedCompletionFilter == 'completed'
          ? context.translate('goal_reached')
          : context.translate('in_progress');
      chips.add(
        _buildFilterBadge(
          context,
          label: label,
          isDark: isDark,
          onDeleted: () {
            setState(() {
              _selectedCompletionFilter = null;
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

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SavingsBloc, BaseState>(
      listener: (final BuildContext context, final BaseState state) {
        if (state is SavingsSuccess) {
          setState(() {
            _items = state.items;
          });
        } else if (state is SavingsError) {
          showSnackbar(context, state.error);
        }
      },
      child: Stack(
        children: <Widget>[
          CustomCardBody(
            isMain: false,
            isMenu: true,
            title: context.translate('savings'),
            description: context.translate('savings_description'),
            buttonText: context.translate('add_saving'),
            buttonIsPrimary: true,
            buttonIsAdd: true,
            onButtonPressed: _addSaving,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildStatCards(context),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyContentWidget(
                          icon: Icons.savings_outlined,
                          title: context.translate('no_savings_found'),
                          subtitle: context.translate('start_by_adding_saving'),
                          actionLabel: context.translate('add_saving'),
                          onAction: _addSaving,
                        )
                      : Builder(
                          builder: (final BuildContext context) {
                            final List<SavingItem> filtered = _filteredItems;
                            final List<SavingItem> paginated = filtered
                                .skip(_currentPage * _itemsPerPage)
                                .take(_itemsPerPage)
                                .toList();

                            return CustomDataTable<SavingItem>(
                              data: paginated,
                              showToolbar: true,
                              minWidth: 1080.0,
                              cellPadding: const EdgeInsets.only(left: 14.0),
                              columnFlexes: const <int>[
                                14, // Goal Name & Tags
                                12, // Category
                                9, // Target Date
                                7, // Currency
                                10, // Current Saved
                                10, // Goal Target
                                14, // Progress bar & %
                                10, // Monthly Needed
                                9, // Status
                              ],
                              isFiltered: _isFilterActive || _showFilterPanel,
                              filterPanel: _showFilterPanel
                                  ? _buildInlineFilterPanel(context)
                                  : null,
                              activeFilterChips:
                                  (_isFilterActive || _searchQuery.isNotEmpty)
                                  ? _buildActiveFilterChips(context)
                                  : null,
                              searchHint: context.translate('search_savings'),
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
                                context.translate('category'),
                                context.translate('target_date'),
                                context.translate('currency'),
                                context.translate('current_saved'),
                                context.translate('goal_amount'),
                                context.translate('progress'),
                                context.translate('monthly_needed'),
                                context.translate('status'),
                              ],
                              rowBuilder: (final SavingItem data) {
                                final Color primaryColor = isDark
                                    ? DarkColors.primary
                                    : LightColors.primary;
                                final double percent = data.progressPercent;
                                final bool completed = data.isCompleted;

                                return <Widget>[
                                  // Name & Category with icon
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Icon(
                                          data.category.icon,
                                          size: 16,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              data.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDark
                                                    ? white
                                                    : LightColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (data.tags.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2.0,
                                                ),
                                                child: Text(
                                                  data.tags.take(2).join(', '),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark
                                                        ? DarkColors
                                                              .textSecondary
                                                        : LightColors
                                                              .textSecondary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Category
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          data.category.toTranslate(context),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Target Date
                                  Text(
                                    _formatDate(data.targetDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? DarkColors.textSecondary
                                          : LightColors.textSecondary,
                                    ),
                                  ),
                                  // Currency
                                  Text(
                                    data.currency,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  // Current Saved
                                  Text(
                                    CurrencyKpiUtils.formatAmount(
                                      data.currentAmount,
                                      data.currency,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: primaryColor,
                                    ),
                                  ),
                                  // Goal Target
                                  Text(
                                    CurrencyKpiUtils.formatAmount(
                                      data.goalAmount,
                                      data.currency,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? white
                                          : LightColors.textPrimary,
                                    ),
                                  ),
                                  // Progress bar & %
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '${percent.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: completed
                                              ? Colors.green
                                              : primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      SizedBox(
                                        width: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: (percent / 100.0).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            minHeight: 5,
                                            backgroundColor: isDark
                                                ? const Color(0xFF334155)
                                                : const Color(0xFFE2E8F0),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  completed
                                                      ? Colors.green
                                                      : primaryColor,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Monthly Contribution Needed
                                  Builder(
                                    builder: (final BuildContext ctx) {
                                      if (completed) {
                                        return Text(
                                          context.translate('goal_reached'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        );
                                      }
                                      final double needed =
                                          data.requiredMonthlyContribution;
                                      if (needed <= 0) {
                                        return Text(
                                          '-',
                                          style: TextStyle(
                                            color: isDark
                                                ? DarkColors.textSecondary
                                                : LightColors.textSecondary,
                                          ),
                                        );
                                      }
                                      return Text(
                                        '${CurrencyKpiUtils.formatAmount(needed, data.currency)} ${context.translate('per_month')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                                  // Status Chip
                                  completed
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 3.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            context.translate('goal_reached'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        )
                                      : CustomChipStatus(isActive: data.status),
                                ];
                              },
                              popupMenuBuilder: (final SavingItem item) {
                                return PrimaryPopupMenu<CustomOptions>(
                                  popupItems: <PopupItem<CustomOptions>>[
                                    PopupItem<CustomOptions>(
                                      title: CustomOptions.recordDeposit
                                          .toTranslate(context),
                                      value: CustomOptions.recordDeposit,
                                    ),
                                    if (item.currentAmount > 0)
                                      PopupItem<CustomOptions>(
                                        title: CustomOptions.recordWithdrawal
                                            .toTranslate(context),
                                        value: CustomOptions.recordWithdrawal,
                                      ),
                                    PopupItem<CustomOptions>(
                                      title: CustomOptions.savingHistory
                                          .toTranslate(context),
                                      value: CustomOptions.savingHistory,
                                    ),
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
                                          case CustomOptions.recordDeposit:
                                            _openRecordTransaction(
                                              item,
                                              CustomSavingTransactionType
                                                  .deposit,
                                            );
                                            break;
                                          case CustomOptions.recordWithdrawal:
                                            _openRecordTransaction(
                                              item,
                                              CustomSavingTransactionType
                                                  .withdrawal,
                                            );
                                            break;
                                          case CustomOptions.savingHistory:
                                            _openHistory(item);
                                            break;
                                          case CustomOptions.edit:
                                            _editSaving(item);
                                            break;
                                          case CustomOptions.delete:
                                            _removeSaving(item);
                                            break;
                                          case CustomOptions.activate:
                                            _toggleSavingStatus(item, true);
                                            break;
                                          case CustomOptions.deactivate:
                                            _toggleSavingStatus(item, false);
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
          BlocBuilder<SavingsBloc, BaseState>(
            buildWhen: (final BaseState previous, final BaseState current) {
              return (previous is SavingsInProgress) !=
                  (current is SavingsInProgress);
            },
            builder: (final BuildContext context, final BaseState state) {
              if (state is SavingsInProgress) {
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
    final List<KpiCardSpec> specs = CurrencyKpiUtils.generateSavingKpiCards(
      items: _items,
      user: _currentUser,
      context: context,
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
              child: SavingStatCard(
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

  void _openRecordTransaction(
    final SavingItem item,
    final CustomSavingTransactionType type,
  ) {
    RecordTransactionDialog.show(
      context: context,
      item: item,
      initialType: type,
      onTransactionRecorded:
          (final SavingItem updated, final SavingRegistryItem t) {
            final String uid =
                FirebaseAuth.instance.currentUser?.uid ?? emptyString;
            _bloc.add(
              SavingTransactionRecorded(
                savingId: item.id,
                transaction: t,
                userId: uid,
              ),
            );
            showSnackbar(
              context,
              t.type == CustomSavingTransactionType.deposit
                  ? context.translate('deposit_success')
                  : context.translate('withdrawal_success'),
            );
          },
    );
  }

  void _openHistory(final SavingItem item) {
    SavingHistoryDialog.show(
      context: context,
      item: item,
      onHistoryUpdated: (final SavingItem updated) {
        final String uid =
            FirebaseAuth.instance.currentUser?.uid ?? emptyString;
        _bloc.add(SavingsFetched(userId: uid));
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
        if (!completer.isCompleted) completer.complete(true);
      },
      onSecondaryButtonTap: () {
        if (!completer.isCompleted) completer.complete(false);
      },
    ).then((_) {
      if (!completer.isCompleted) completer.complete(false);
    });
    return completer.future;
  }

  void _openDrawer() {
    DrawerWidget.show(
      context: context,
      title: context.translate(_isEditing ? 'edit_saving' : 'add_saving'),
      builder: (final BuildContext dialogContext) {
        return FormWidget(
          savingItem: _editingItem,
          isEdit: _isEditing,
          onSave: (final SavingItem item) {
            if (_isEditing) {
              _bloc.add(SavingUpdated(item: item));
            } else {
              _bloc.add(SavingAdded(item: item));
            }
            Navigator.of(dialogContext).pop();
            showSnackbar(
              context,
              context.translate('saving_saved_successfully'),
            );
          },
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _addSaving() {
    _editingItem = null;
    _isEditing = false;
    _openDrawer();
  }

  void _editSaving(final SavingItem item) {
    _editingItem = item;
    _isEditing = true;
    _openDrawer();
  }

  void _removeSaving(final SavingItem item) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate('confirm_removal'),
      context.translate('confirm_saving_delete'),
    );
    if (confirmed == true) {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? emptyString;
      _bloc.add(SavingDeleted(id: item.id, userId: uid));
      showSnackbar(context, context.translate('saving_deleted'));
    }
  }

  void _toggleSavingStatus(final SavingItem item, final bool newStatus) async {
    final bool? confirmed = await _showConfirmation(
      context,
      context.translate(
        newStatus ? 'confirm_activation' : 'confirm_deactivation',
      ),
      context.translate(
        newStatus ? 'confirm_saving_activation' : 'confirm_saving_deactivation',
      ),
    );
    if (confirmed == true) {
      final SavingItem updated = item.copyWith(status: newStatus);
      _bloc.add(SavingUpdated(item: updated));
      showSnackbar(
        context,
        context.translate(
          newStatus ? 'saving_activated' : 'saving_deactivated',
        ),
      );
    }
  }
}
