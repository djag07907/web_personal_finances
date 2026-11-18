part of 'accounts_to_pay_body.dart';

class FormWidget extends StatefulWidget {
  final AccountToPayItem? accountToPayItem;
  final bool isEdit;
  final void Function(AccountToPayItem) onSave;
  final VoidCallback onClose;

  const FormWidget({
    super.key,
    this.accountToPayItem,
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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? selectedCurrency;
  CustomAccountToPayCategoryOptions? selectedCategory;
  CustomFrequencyOptions? selectedFrequency;
  CustomInterestType selectedInterestType = CustomInterestType.french;
  bool isPaid = false;
  bool isLoan = false;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _initialPaidQuotasController =
      TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _totalQuotasController = TextEditingController();
  final TextEditingController _monthlyQuotaController = TextEditingController();
  DateTime? _selectedStartDate;
  bool _isRetroactiveUpToDate = true;
  List<String> tags = <String>[];
  List<String> _availableCurrencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.accountToPayItem != null) {
      final AccountToPayItem item = widget.accountToPayItem!;
      _nameController.text = item.creditorName;
      _descriptionController.text = item.description;
      _amountController.text = item.amount.toString();
      _selectedStartDate = item.startDate;
      if (item.startDate != null) {
        _startDateController.text = DateFormat(
          dayMonthYearFormat,
        ).format(item.startDate!);
      }
      _dueDateController.text = DateFormat(
        dayMonthYearFormat,
      ).format(item.dueDate);
      selectedCurrency = item.currency;
      selectedCategory = item.category;
      selectedFrequency = item.frequency;
      selectedInterestType = item.interestType;
      isPaid = item.isPaid;
      tags = item.tags;
      isLoan = item.isLoanAccount;
      if (item.interestRate != null) {
        _interestRateController.text = item.interestRate.toString();
      }
      if (item.totalQuotas != null) {
        _totalQuotasController.text = item.totalQuotas.toString();
      }
      if (item.monthlyQuota != null) {
        _monthlyQuotaController.text = item.monthlyQuota.toString();
      }
      if (item.initialPaidQuotas != null) {
        _initialPaidQuotasController.text = item.initialPaidQuotas.toString();
        _isRetroactiveUpToDate = false;
      }
    } else {
      selectedCategory = CustomAccountToPayCategoryOptions.other;
      selectedFrequency = CustomFrequencyOptions.once;
      selectedInterestType = CustomInterestType.french;
      isPaid = false;
      isLoan = false;
    }
    _amountController.addListener(_onFieldChanged);
    _interestRateController.addListener(_onFieldChanged);
    _totalQuotasController.addListener(_onFieldChanged);
    _loadUserCurrencies();
  }

  void _onFieldChanged() {
    _syncCalculatedQuota();
    if (mounted) {
      setState(() {});
    }
  }

  void _syncCalculatedQuota({final bool force = false}) {
    final double p =
        double.tryParse(_amountController.text.replaceAll(',', emptyString)) ??
        0.0;
    final double r =
        double.tryParse(_interestRateController.text.trim()) ?? 0.0;
    final int n = int.tryParse(_totalQuotasController.text.trim()) ?? 0;

    if (p > 0 && n > 0) {
      final double estQuota = LoanAmortizationUtils.calculatePeriodicQuota(
        principal: p,
        annualInterestRatePercent: r,
        totalQuotas: n,
        frequency: selectedFrequency ?? CustomFrequencyOptions.monthly,
        interestType: selectedInterestType,
      );
      if (force || _monthlyQuotaController.text.isEmpty) {
        _monthlyQuotaController.text = estQuota.toStringAsFixed(2);
      }
    }
  }

  int get _elapsedQuotas {
    if (_selectedStartDate == null) {
      return 0;
    }
    return LoanAmortizationUtils.calculateElapsedPeriods(
      startDate: _selectedStartDate!,
      frequency: selectedFrequency ?? CustomFrequencyOptions.monthly,
    );
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
    _amountController.removeListener(_onFieldChanged);
    _interestRateController.removeListener(_onFieldChanged);
    _totalQuotasController.removeListener(_onFieldChanged);
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _startDateController.dispose();
    _dueDateController.dispose();
    _initialPaidQuotasController.dispose();
    _interestRateController.dispose();
    _totalQuotasController.dispose();
    _monthlyQuotaController.dispose();
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
                    items: CustomAccountToPayCategoryOptions.values
                        .map(
                          (final CustomAccountToPayCategoryOptions element) =>
                              element.toTranslate(context),
                        )
                        .toList(),
                    onChanged: (final String? selectedLabel) {
                      setState(() {
                        selectedCategory = CustomAccountToPayCategoryOptions
                            .values
                            .firstWhere(
                              (
                                final CustomAccountToPayCategoryOptions element,
                              ) =>
                                  element.toTranslate(context) == selectedLabel,
                            );
                        if (selectedCategory ==
                                CustomAccountToPayCategoryOptions.loan ||
                            selectedCategory ==
                                CustomAccountToPayCategoryOptions.mortgage ||
                            selectedCategory ==
                                CustomAccountToPayCategoryOptions
                                    .installmentDebt) {
                          isLoan = true;
                          if (selectedFrequency ==
                              CustomFrequencyOptions.once) {
                            selectedFrequency = CustomFrequencyOptions.monthly;
                          }
                        }
                      });
                    },
                  ),
                  CustomLabelSelector(
                    label: context.translate('frequency'),
                    hintText: context.translate('select_frequency'),
                    validator: (final String? value) {
                      if (value == null) {
                        return context.translate('please_select_frequency');
                      }
                      return null;
                    },
                    selectedValue: selectedFrequency?.toTranslate(context),
                    items: CustomFrequencyOptions.values
                        .map(
                          (final CustomFrequencyOptions element) =>
                              element.toTranslate(context),
                        )
                        .toList(),
                    onChanged: (final String? selectedLabel) {
                      setState(() {
                        selectedFrequency = CustomFrequencyOptions.values
                            .firstWhere(
                              (final CustomFrequencyOptions element) =>
                                  element.toTranslate(context) == selectedLabel,
                            );
                      });
                    },
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
                  CustomLabelInput(
                    label: context.translate('creditor_name'),
                    hintText: context.translate('enter_creditor_name'),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_creditor_name');
                      }
                      return null;
                    },
                    controller: _nameController,
                  ),
                  CustomLabelInput(
                    label: context.translate('description'),
                    hintText: context.translate('enter_description'),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_description');
                      }
                      return null;
                    },
                    controller: _descriptionController,
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
                    label: isLoan
                        ? context.translate('total_loan_amount_label')
                        : context.translate('total_amount_due_label'),
                    hintText: isLoan
                        ? context.translate('total_loan_amount_hint')
                        : context.translate('total_amount_due_hint'),
                    helperText: isLoan
                        ? context.translate('total_loan_amount_helper')
                        : context.translate('total_amount_due_helper'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <MoneyInputFormatter>[
                      MoneyInputFormatter(),
                    ],
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return isLoan
                            ? context.translate(
                                'please_enter_total_loan_amount',
                              )
                            : context.translate(
                                'please_enter_total_amount_due',
                              );
                      }
                      return null;
                    },
                    controller: _amountController,
                  ),
                  CustomLabelInput(
                    label: context.translate('start_date'),
                    hintText: context.translate('enter_start_date'),
                    isReadOnly: true,
                    isCalendar: true,
                    onTap: () async {
                      final CustomCalendarDialog calendar =
                          CustomCalendarDialog();
                      final DateTime? selectedDate = await calendar
                          .showDateDialog(
                            context: context,
                            dateController: _startDateController,
                          );
                      if (selectedDate != null) {
                        setState(() {
                          _selectedStartDate = selectedDate;
                          _startDateController.text = DateFormat(
                            dayMonthYearFormat,
                          ).format(selectedDate);
                          if (_isRetroactiveUpToDate) {
                            _initialPaidQuotasController.text = _elapsedQuotas
                                .toString();
                          }
                        });
                      }
                    },
                    validator: (final String? value) => null,
                    controller: _startDateController,
                  ),
                  CustomLabelInput(
                    label: isLoan
                        ? context.translate('first_payment_date')
                        : context.translate('date_due'),
                    hintText: isLoan
                        ? context.translate('enter_first_payment_date')
                        : context.translate('enter_due_date'),
                    isReadOnly: true,
                    isCalendar: true,
                    onTap: () async {
                      final CustomCalendarDialog calendar =
                          CustomCalendarDialog();
                      final DateTime? selectedDate = await calendar
                          .showDateDialog(
                            context: context,
                            dateController: _dueDateController,
                          );
                      if (selectedDate != null) {
                        _dueDateController.text = DateFormat(
                          dayMonthYearFormat,
                        ).format(selectedDate);
                      }
                    },
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_date_due');
                      }
                      return null;
                    },
                    controller: _dueDateController,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          context.translate('is_loan'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                        ),
                        Switch(
                          value: isLoan,
                          activeThumbColor: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          onChanged: (final bool value) {
                            setState(() {
                              isLoan = value;
                              if (value &&
                                  selectedFrequency ==
                                      CustomFrequencyOptions.once) {
                                selectedFrequency =
                                    CustomFrequencyOptions.monthly;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isLoan) ...<Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? DarkColors.primary : LightColors.primary)
                                .withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color:
                              (isDark
                                      ? DarkColors.primary
                                      : LightColors.primary)
                                  .withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            context.translate('loan_details'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? white : LightColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomLabelSelector(
                            label: context.translate('interest_type'),
                            hintText: context.translate('interest_type'),
                            validator: (final String? value) => null,
                            selectedValue: selectedInterestType.toTranslate(
                              context,
                            ),
                            items: CustomInterestType.values
                                .map(
                                  (final CustomInterestType e) =>
                                      e.toTranslate(context),
                                )
                                .toList(),
                            onChanged: (final String? selectedLabel) {
                              setState(() {
                                selectedInterestType = CustomInterestType.values
                                    .firstWhere(
                                      (final CustomInterestType e) =>
                                          e.toTranslate(context) ==
                                          selectedLabel,
                                      orElse: () => CustomInterestType.french,
                                    );
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              selectedInterestType.description(context),
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                            ),
                          ),
                          CustomLabelInput(
                            label: context.translate('interest_rate'),
                            hintText: context.translate('interest_rate_hint'),
                            inputFormatters: <TextInputFormatter>[
                              DecimalInputFormatter(decimalRange: 2),
                            ],
                            validator: (final String? value) {
                              if (!isLoan) {
                                return null;
                              }
                              if (value == null || value.trim().isEmpty) {
                                return context.translate(
                                  'please_enter_interest_rate',
                                );
                              }
                              final double? parsed = double.tryParse(
                                value.trim(),
                              );
                              if (parsed == null ||
                                  parsed < 0 ||
                                  parsed > 100) {
                                return context.translate(
                                  'please_enter_valid_interest_rate',
                                );
                              }
                              return null;
                            },
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            controller: _interestRateController,
                          ),
                          CustomLabelInput(
                            label: context.translate('total_quotas'),
                            hintText: context.translate('total_quotas_hint'),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (final String? value) {
                              if (!isLoan) {
                                return null;
                              }
                              if (value == null || value.trim().isEmpty) {
                                return context.translate(
                                  'please_enter_total_quotas',
                                );
                              }
                              final int? parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) {
                                return context.translate(
                                  'please_enter_valid_total_quotas',
                                );
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: _totalQuotasController,
                          ),
                          Builder(
                            builder: (final BuildContext ctx) {
                              final double p =
                                  double.tryParse(
                                    _amountController.text.replaceAll(
                                      ',',
                                      emptyString,
                                    ),
                                  ) ??
                                  0.0;
                              final double r =
                                  double.tryParse(
                                    _interestRateController.text.trim(),
                                  ) ??
                                  0.0;
                              final int n =
                                  int.tryParse(
                                    _totalQuotasController.text.trim(),
                                  ) ??
                                  0;

                              if (p > 0 && n > 0) {
                                final double estQuota =
                                    LoanAmortizationUtils.calculatePeriodicQuota(
                                      principal: p,
                                      annualInterestRatePercent: r,
                                      totalQuotas: n,
                                      frequency:
                                          selectedFrequency ??
                                          CustomFrequencyOptions.monthly,
                                      interestType: selectedInterestType,
                                    );
                                final double totalInterest = (estQuota * n) - p;
                                final String cur =
                                    selectedCurrency ?? emptyString;

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${context.translate('monthly_quota')}: ~${CurrencyKpiUtils.formatAmount(estQuota, cur)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${context.translate('total_interest')}: ~${CurrencyKpiUtils.formatAmount(totalInterest < 0 ? 0 : totalInterest, cur)}',
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
                            label: context.translate('custom_monthly_quota'),
                            hintText: context.translate('monthly_quota_hint'),
                            trailingLabel: TextButton.icon(
                              onPressed: () {
                                _syncCalculatedQuota(force: true);
                              },
                              icon: const Icon(Icons.sync, size: 14),
                              label: Text(
                                context.translate('recalculate_quota'),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            validator: null,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: <MoneyInputFormatter>[
                              MoneyInputFormatter(),
                            ],
                            controller: _monthlyQuotaController,
                          ),
                          if (_selectedStartDate != null &&
                              _selectedStartDate!.isBefore(
                                DateTime.now(),
                              )) ...<Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.history,
                                        size: 18,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.translate(
                                          'retroactive_calculation',
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? white
                                              : LightColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.translate(
                                      'retroactive_calculation_desc',
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? DarkColors.textSecondary
                                          : LightColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          context.translate(
                                            'is_debt_up_to_date',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _isRetroactiveUpToDate,
                                        activeThumbColor: isDark
                                            ? DarkColors.primary
                                            : LightColors.primary,
                                        onChanged: (final bool val) {
                                          setState(() {
                                            _isRetroactiveUpToDate = val;
                                            if (val) {
                                              _initialPaidQuotasController
                                                  .text = _elapsedQuotas
                                                  .toString();
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if (_isRetroactiveUpToDate) ...<Widget>[
                                    Text(
                                      context.translate(
                                        'elapsed_quotas_summary',
                                        namedArgs: <String, String>{
                                          'count': '$_elapsedQuotas',
                                          'amount':
                                              CurrencyKpiUtils.formatAmount(
                                                _elapsedQuotas *
                                                    (double.tryParse(
                                                          _monthlyQuotaController
                                                              .text
                                                              .replaceAll(
                                                                ',',
                                                                emptyString,
                                                              ),
                                                        ) ??
                                                        0.0),
                                                selectedCurrency ?? emptyString,
                                              ),
                                        },
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else ...<Widget>[
                                    CustomLabelInput(
                                      label: context.translate(
                                        'quotas_already_paid',
                                      ),
                                      hintText: context.translate(
                                        'enter_quotas_already_paid',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: null,
                                      controller: _initialPaidQuotasController,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          context.translate('is_paid'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                        ),
                        Switch(
                          value: isPaid,
                          activeThumbColor: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          onChanged: (final bool value) {
                            setState(() {
                              isPaid = value;
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
    final AccountToPayItem? existing = widget.isEdit
        ? widget.accountToPayItem
        : null;
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;

    DateTime? paymentDate;
    if (isPaid) {
      paymentDate = (existing != null && existing.isPaid)
          ? existing.paymentDate
          : DateTime.now();
      paymentDate ??= DateTime.now();
    }

    final double parsedAmount =
        double.tryParse(_amountController.text.replaceAll(',', emptyString)) ??
        0.0;
    final DateTime dueDate = DateFormat(
      dayMonthYearFormat,
    ).parse(_dueDateController.text);
    final int totalQ = int.tryParse(_totalQuotasController.text.trim()) ?? 0;
    final double? parsedRate = isLoan
        ? double.tryParse(_interestRateController.text.trim())
        : null;
    final double? customMonthlyQuota = isLoan
        ? double.tryParse(
            _monthlyQuotaController.text.replaceAll(',', emptyString),
          )
        : null;

    int initialPaid = 0;
    if (isLoan &&
        _selectedStartDate != null &&
        _selectedStartDate!.isBefore(DateTime.now())) {
      if (_isRetroactiveUpToDate) {
        initialPaid = math.min(
          _elapsedQuotas,
          totalQ > 0 ? totalQ : _elapsedQuotas,
        );
      } else {
        initialPaid =
            int.tryParse(_initialPaidQuotasController.text.trim()) ?? 0;
      }
    } else if (existing?.initialPaidQuotas != null) {
      initialPaid = existing!.initialPaidQuotas!;
    }

    // Preserve non-retroactive manual payments
    final List<AccountToPayPayment> preservedPayments = existing != null
        ? existing.payments
              .where(
                (final AccountToPayPayment p) => !p.id.startsWith('retro_'),
              )
              .toList()
        : <AccountToPayPayment>[];

    final List<AccountToPayPayment> allPayments = <AccountToPayPayment>[];
    if (isLoan && initialPaid > 0) {
      final AccountToPayItem temp = AccountToPayItem(
        id: existing?.id ?? 'temp',
        creditorName: _nameController.text,
        description: _descriptionController.text,
        amount: parsedAmount,
        currency: selectedCurrency!,
        startDate: _selectedStartDate,
        dueDate: dueDate,
        category: selectedCategory ?? CustomAccountToPayCategoryOptions.other,
        frequency: selectedFrequency ?? CustomFrequencyOptions.monthly,
        isLoan: true,
        interestRate: parsedRate,
        totalQuotas: totalQ > 0 ? totalQ : null,
        monthlyQuota: customMonthlyQuota,
        interestType: selectedInterestType,
      );
      final List<AmortizationScheduleItem> schedule =
          LoanAmortizationUtils.generateSchedule(temp);
      final int count = math.min(initialPaid, schedule.length);
      for (int k = 1; k <= count; k++) {
        final AmortizationScheduleItem q = schedule[k - 1];
        allPayments.add(
          AccountToPayPayment(
            id: 'retro_${temp.id}_$k',
            amount: q.quotaAmount,
            paymentDate: q.dueDate,
            paymentMethod: context.translate('retroactive_payment_method'),
            notes: context.translate(
              'retroactive_payment_note',
              namedArgs: <String, String>{'number': '$k'},
            ),
          ),
        );
      }
    }
    allPayments.addAll(preservedPayments);

    final bool effectivelyPaid =
        isPaid || (isLoan && totalQ > 0 && initialPaid >= totalQ);

    final AccountToPayItem newItem = AccountToPayItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (existing != null && existing.userId.isNotEmpty)
          ? existing.userId
          : currentUid,
      creditorName: _nameController.text,
      description: _descriptionController.text,
      currency: selectedCurrency!,
      amount: parsedAmount,
      startDate: _selectedStartDate,
      dueDate: dueDate,
      paymentDate: paymentDate,
      isPaid: effectivelyPaid,
      status: existing?.status ?? true,
      category: selectedCategory ?? CustomAccountToPayCategoryOptions.other,
      frequency: selectedFrequency ?? CustomFrequencyOptions.once,
      createdDate: existing?.createdDate ?? DateTime.now(),
      tags: tags,
      paymentMethod: existing?.paymentMethod,
      payments: allPayments,
      isLoan: isLoan,
      interestRate: parsedRate,
      totalQuotas: isLoan && totalQ > 0 ? totalQ : null,
      monthlyQuota: customMonthlyQuota,
      interestType: selectedInterestType,
      initialPaidQuotas: initialPaid > 0 ? initialPaid : null,
    );

    widget.onSave(newItem);
  }
}
