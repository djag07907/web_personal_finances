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
  bool isPaid = false;
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
      _dueDateController.text = DateFormat(
        dayMonthYearFormat,
      ).format(item.dueDate);
      selectedCurrency = item.currency;
      selectedCategory = item.category;
      selectedFrequency = item.frequency;
      isPaid = item.isPaid;
      tags = item.tags;
    } else {
      selectedCategory = CustomAccountToPayCategoryOptions.other;
      selectedFrequency = CustomFrequencyOptions.once;
      isPaid = false;
    }
    _loadUserCurrencies();
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
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
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
      // Keep the original payment date if it was already paid.
      paymentDate = (existing != null && existing.isPaid)
          ? existing.paymentDate
          : DateTime.now();
      paymentDate ??= DateTime.now();
    }

    final AccountToPayItem newItem = AccountToPayItem(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: (existing != null && existing.userId.isNotEmpty)
          ? existing.userId
          : currentUid,
      creditorName: _nameController.text,
      description: _descriptionController.text,
      currency: selectedCurrency!,
      amount:
          double.tryParse(
            _amountController.text.replaceAll(',', emptyString),
          ) ??
          0,
      dueDate: DateFormat(dayMonthYearFormat).parse(_dueDateController.text),
      paymentDate: paymentDate,
      isPaid: isPaid,
      status: existing?.status ?? true,
      category: selectedCategory ?? CustomAccountToPayCategoryOptions.other,
      frequency: selectedFrequency ?? CustomFrequencyOptions.once,
      createdDate: existing?.createdDate ?? DateTime.now(),
      tags: tags,
      paymentMethod: existing?.paymentMethod,
    );

    widget.onSave(newItem);
  }
}
