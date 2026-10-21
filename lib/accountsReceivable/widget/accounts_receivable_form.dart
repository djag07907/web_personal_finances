part of 'accounts_receivable_body.dart';

class FormWidget extends StatefulWidget {
  final AccountReceivableItem? accountReceivableItem;
  final bool isEdit;
  final void Function(AccountReceivableItem) onSave;
  final VoidCallback onClose;

  const FormWidget({
    super.key,
    this.accountReceivableItem,
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
  CustomAccountReceivableCategoryOptions? selectedCategory;
  CustomFrequencyOptions? selectedFrequency;
  CustomInterestType selectedInterestType = CustomInterestType.flat;
  bool isReceived = false;
  bool isLoan = false;
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _totalQuotasController = TextEditingController();
  final TextEditingController _monthlyQuotaController = TextEditingController();
  List<String> tags = <String>[];
  List<String> _availableCurrencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.accountReceivableItem != null) {
      final AccountReceivableItem item = widget.accountReceivableItem!;
      _nameController.text = item.debtorName;
      _descriptionController.text = item.description;
      _amountController.text = item.amount.toString();
      _dueDateController.text = DateFormat(
        dayMonthYearFormat,
      ).format(item.dueDate);
      selectedCurrency = item.currency;
      selectedCategory = item.category;
      selectedFrequency = item.frequency;
      selectedInterestType = item.interestType;
      isReceived = item.isReceived;
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
    } else {
      selectedCategory = CustomAccountReceivableCategoryOptions.other;
      selectedFrequency = CustomFrequencyOptions.once;
      selectedInterestType = CustomInterestType.flat;
      isReceived = false;
      isLoan = false;
    }
    _amountController.addListener(_onFieldChanged);
    _interestRateController.addListener(_onFieldChanged);
    _totalQuotasController.addListener(_onFieldChanged);
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
    _amountController.removeListener(_onFieldChanged);
    _interestRateController.removeListener(_onFieldChanged);
    _totalQuotasController.removeListener(_onFieldChanged);
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
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
                    items: CustomAccountReceivableCategoryOptions.values
                        .map(
                          (
                            final CustomAccountReceivableCategoryOptions
                            element,
                          ) => element.toTranslate(context),
                        )
                        .toList(),
                    onChanged: (final String? selectedLabel) {
                      setState(() {
                        selectedCategory =
                            CustomAccountReceivableCategoryOptions.values
                                .firstWhere(
                                  (
                                    final CustomAccountReceivableCategoryOptions
                                    element,
                                  ) =>
                                      element.toTranslate(context) ==
                                      selectedLabel,
                                );
                        if (selectedCategory ==
                                CustomAccountReceivableCategoryOptions
                                    .personalLoan ||
                            selectedCategory ==
                                CustomAccountReceivableCategoryOptions
                                    .promissoryNote) {
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
                    label: context.translate('debtor_name'),
                    hintText: context.translate('please_enter_debtor_name'),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_debtor_name');
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
                    label: context.translate('amount'),
                    hintText: context.translate('enter_amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <MoneyInputFormatter>[
                      MoneyInputFormatter(),
                    ],
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_amount');
                      }
                      return null;
                    },
                    controller: _amountController,
                  ),
                  CustomLabelInput(
                    label: context.translate('date_due'),
                    hintText: context.translate('enter_due_date'),
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
                          context.translate('is_financing'),
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
                            context.translate('financing_details'),
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
                                      orElse: () => CustomInterestType.flat,
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
                            validator: null,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: <MoneyInputFormatter>[
                              MoneyInputFormatter(),
                            ],
                            controller: _monthlyQuotaController,
                          ),
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
                          context.translate('is_received'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                        ),
                        Switch(
                          value: isReceived,
                          activeThumbColor: isDark
                              ? DarkColors.primary
                              : LightColors.primary,
                          onChanged: (final bool value) {
                            setState(() {
                              isReceived = value;
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
    final AccountReceivableItem? existing = widget.isEdit
        ? widget.accountReceivableItem
        : null;
    final String currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? emptyString;

    DateTime? paymentDate;
    if (isReceived) {
      paymentDate = (existing != null && existing.isReceived)
          ? existing.paymentDate
          : DateTime.now();
      paymentDate ??= DateTime.now();
    }

    final AccountReceivableItem newItem = AccountReceivableItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (existing != null && existing.userId.isNotEmpty)
          ? existing.userId
          : currentUid,
      debtorName: _nameController.text,
      description: _descriptionController.text,
      currency: selectedCurrency!,
      amount:
          double.tryParse(
            _amountController.text.replaceAll(',', emptyString),
          ) ??
          0,
      dueDate: DateFormat(dayMonthYearFormat).parse(_dueDateController.text),
      paymentDate: paymentDate,
      isReceived: isReceived,
      status: existing?.status ?? true,
      category:
          selectedCategory ?? CustomAccountReceivableCategoryOptions.other,
      frequency: selectedFrequency ?? CustomFrequencyOptions.once,
      createdDate: existing?.createdDate ?? DateTime.now(),
      tags: tags,
      paymentMethod: existing?.paymentMethod,
      payments: existing?.payments ?? const <AccountReceivablePayment>[],
      isLoan: isLoan,
      interestRate: isLoan
          ? double.tryParse(_interestRateController.text.trim())
          : null,
      totalQuotas: isLoan
          ? int.tryParse(_totalQuotasController.text.trim())
          : null,
      monthlyQuota: isLoan
          ? double.tryParse(
              _monthlyQuotaController.text.replaceAll(',', emptyString),
            )
          : null,
      interestType: selectedInterestType,
    );

    widget.onSave(newItem);
  }
}
