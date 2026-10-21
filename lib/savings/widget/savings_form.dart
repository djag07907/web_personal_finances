part of 'savings_body.dart';

class FormWidget extends StatefulWidget {
  final SavingItem? savingItem;
  final bool isEdit;
  final void Function(SavingItem) onSave;
  final VoidCallback onClose;

  const FormWidget({
    super.key,
    this.savingItem,
    this.isEdit = false,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _initialAmountController =
      TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  CustomSavingCategoryOptions? selectedCategory;
  String? selectedCurrency;
  DateTime? selectedTargetDate;
  bool isGoalReached = false;
  bool status = true;
  List<String> tags = <String>[];
  List<String> _availableCurrencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.savingItem != null) {
      final SavingItem item = widget.savingItem!;
      _nameController.text = item.name;
      _commentController.text = item.comment;
      _initialAmountController.text = item.amount.toString();
      _goalAmountController.text = item.goalAmount.toString();
      selectedCurrency = item.currency;
      selectedCategory = item.category;
      isGoalReached = item.isGoalReached;
      status = item.status;
      tags = item.tags;
      if (item.targetDate != null) {
        selectedTargetDate = item.targetDate;
        _targetDateController.text = DateFormat(
          dayMonthYearFormat,
        ).format(item.targetDate!);
      }
    } else {
      selectedCategory = CustomSavingCategoryOptions.emergencyFund;
      isGoalReached = false;
      status = true;
      _initialAmountController.text = '0.00';
    }
    _initialAmountController.addListener(_onFieldChanged);
    _goalAmountController.addListener(_onFieldChanged);
    _loadUserCurrencies();
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserCurrencies() async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    UserModel? user;
    try {
      user = context.read<AppAuthNotifier>().userProfile;
    } catch (_) {}

    if (user == null && authUser != null) {
      try {
        final UserRepository userRepository = context.read<UserRepository>();
        user = await userRepository.getUser(authUser.uid);
      } catch (_) {}
    }

    if (user != null) {
      final String primary = user.primaryCurrency.isNotEmpty
          ? user.primaryCurrency
          : usdCurrency;
      final String secondary = primary == hnlCurrency
          ? usdCurrency
          : hnlCurrency;
      final List<String> allowed = <String>[primary, secondary];

      if (mounted) {
        setState(() {
          _availableCurrencies = allowed;
          if (!widget.isEdit ||
              selectedCurrency == null ||
              !_availableCurrencies.contains(selectedCurrency)) {
            selectedCurrency = primary;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _initialAmountController.removeListener(_onFieldChanged);
    _goalAmountController.removeListener(_onFieldChanged);
    _scrollController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    _initialAmountController.dispose();
    _goalAmountController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(12.0),
        border: isDark ? Border.all(color: DarkColors.border, width: 1) : null,
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                right: 14.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomLabelSelector(
                    label: context.translate('category'),
                    hintText: context.translate('select_category'),
                    validator: (final String? value) {
                      if (value == null) {
                        return context.translate('please_select_category');
                      }
                      return null;
                    },
                    selectedValue: selectedCategory?.toTranslate(context),
                    items: CustomSavingCategoryOptions.values
                        .map(
                          (final CustomSavingCategoryOptions e) =>
                              e.toTranslate(context),
                        )
                        .toList(),
                    onChanged: (final String? selectedLabel) {
                      setState(() {
                        selectedCategory = CustomSavingCategoryOptions.values
                            .firstWhere(
                              (final CustomSavingCategoryOptions e) =>
                                  e.toTranslate(context) == selectedLabel,
                            );
                      });
                    },
                  ),
                  CustomLabelInput(
                    label: context.translate('saving_name'),
                    hintText: context.translate('enter_saving_name'),
                    validator: (final String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('please_enter_saving_name');
                      }
                      return null;
                    },
                    controller: _nameController,
                  ),
                  CustomLabelSelector(
                    label: context.translate('currency'),
                    hintText: context.translate('select_currency'),
                    validator: (final String? value) {
                      if (value == null) {
                        return context.translate('please_select_currency');
                      }
                      return null;
                    },
                    selectedValue: selectedCurrency,
                    items: _availableCurrencies,
                    onChanged: (final String? value) {
                      setState(() {
                        selectedCurrency = value;
                      });
                    },
                  ),
                  CustomLabelInput(
                    label: context.translate('goal_amount'),
                    hintText: context.translate('enter_goal_amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <MoneyInputFormatter>[
                      MoneyInputFormatter(),
                    ],
                    validator: (final String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('please_enter_goal_amount');
                      }
                      final double? parsed = double.tryParse(
                        value.replaceAll(',', emptyString),
                      );
                      if (parsed == null || parsed <= 0) {
                        return context.translate(
                          'please_enter_valid_goal_amount',
                        );
                      }
                      return null;
                    },
                    controller: _goalAmountController,
                  ),
                  CustomLabelInput(
                    label: widget.isEdit
                        ? context.translate('initial_deposit')
                        : '${context.translate('initial_deposit')} (${context.translate('optional')})',
                    hintText: context.translate('enter_amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <MoneyInputFormatter>[
                      MoneyInputFormatter(),
                    ],
                    validator: null,
                    controller: _initialAmountController,
                  ),
                  CustomLabelInput(
                    label:
                        '${context.translate('target_date')} (${context.translate('optional')})',
                    hintText: context.translate('target_date_hint'),
                    isReadOnly: true,
                    isCalendar: true,
                    onTap: () async {
                      final CustomCalendarDialog calendar =
                          CustomCalendarDialog();
                      final DateTime? selected = await calendar.showDateDialog(
                        context: context,
                        dateController: _targetDateController,
                      );
                      if (selected != null) {
                        setState(() {
                          selectedTargetDate = selected;
                          _targetDateController.text = DateFormat(
                            dayMonthYearFormat,
                          ).format(selected);
                        });
                      }
                    },
                    validator: null,
                    controller: _targetDateController,
                  ),

                  // Dynamic Pacing Preview
                  Builder(
                    builder: (final BuildContext ctx) {
                      final double goal =
                          double.tryParse(
                            _goalAmountController.text.replaceAll(
                              ',',
                              emptyString,
                            ),
                          ) ??
                          0.0;
                      final double initial =
                          double.tryParse(
                            _initialAmountController.text.replaceAll(
                              ',',
                              emptyString,
                            ),
                          ) ??
                          0.0;
                      final double remaining = math.max(0.0, goal - initial);

                      if (goal > 0 &&
                          selectedTargetDate != null &&
                          selectedTargetDate!.isAfter(DateTime.now()) &&
                          remaining > 0) {
                        final int months = SavingUtils.getRemainingMonths(
                          selectedTargetDate!,
                        );
                        final double monthlyNeeded = months > 0
                            ? remaining / months
                            : remaining;
                        final String cur = selectedCurrency ?? emptyString;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${context.translate('monthly_contribution_needed')}: ~${CurrencyKpiUtils.formatAmount(monthlyNeeded, cur)} ${context.translate('per_month')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.translate(
                                  'months_remaining_to_save',
                                  namedArgs: <String, String>{
                                    'months': '$months',
                                    'amount': CurrencyKpiUtils.formatAmount(
                                      remaining,
                                      cur,
                                    ),
                                  },
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  CustomLabelInput(
                    label: context.translate('comment'),
                    hintText: context.translate('enter_comment'),
                    validator: null,
                    controller: _commentController,
                  ),
                  CustomChipTag(
                    label:
                        '${context.translate('tags')} (${context.translate('optional')})',
                    hintText: context.translate('enter_tags'),
                    initialTags: tags,
                    onChanged: (final List<String> updatedTags) {
                      setState(() {
                        tags = updatedTags;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          context.translate('active'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                        ),
                        Switch(
                          value: status,
                          activeThumbColor: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          onChanged: (final bool value) {
                            setState(() {
                              status = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    spacing: 15.0,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: CustomButton(
                          text: context.translate('cancel'),
                          isPrimary: false,
                          onPressed: widget.onClose,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: CustomButton(
                          text: context.translate('save'),
                          isPrimary: true,
                          onPressed: _onSavePressed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final SavingItem? existing = widget.isEdit ? widget.savingItem : null;
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;

    final double goal =
        double.tryParse(
          _goalAmountController.text.replaceAll(',', emptyString),
        ) ??
        0.0;
    final double initial =
        double.tryParse(
          _initialAmountController.text.replaceAll(',', emptyString),
        ) ??
        0.0;

    final SavingItem newItem = SavingItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (existing != null && existing.userId.isNotEmpty)
          ? existing.userId
          : currentUid,
      name: _nameController.text.trim(),
      comment: _commentController.text.trim(),
      currency: selectedCurrency!,
      amount: initial,
      goalAmount: goal,
      targetDate: selectedTargetDate,
      category: selectedCategory ?? CustomSavingCategoryOptions.emergencyFund,
      isGoalReached: existing?.isGoalReached ?? (initial >= goal && goal > 0),
      status: status,
      createdDate: existing?.createdDate ?? DateTime.now(),
      tags: tags,
      registries: existing?.registries ?? const <SavingRegistryItem>[],
    );

    widget.onSave(newItem);
  }
}
