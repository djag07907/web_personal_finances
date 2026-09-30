part of 'incomes_body.dart';

class FormWidget extends StatefulWidget {
  final IncomeItem? incomeItem;
  final bool isEdit;
  final void Function(IncomeItem) onSave;
  final VoidCallback onClose;

  const FormWidget({
    super.key,
    this.incomeItem,
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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateToReceiveController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String incomeName;
  late String incomeComment;
  late double incomeAmount;
  String? selectedCurrency;
  CustomFrequencyOptions? selectedFrequency;
  List<String> tags = <String>[];
  List<String> _availableCurrencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    _loadUserCurrencies();
    if (widget.isEdit && widget.incomeItem != null) {
      _nameController.text = widget.incomeItem!.name;
      _commentController.text = widget.incomeItem!.comment;
      _amountController.text = widget.incomeItem!.amount.toString();
      _dateToReceiveController.text = widget.incomeItem!.dateToReceive
          .toString();
      selectedCurrency = widget.incomeItem!.currency;
      if (widget.isEdit && widget.incomeItem != null) {
        selectedFrequency = widget.incomeItem!.frequency;
      }
      tags = widget.incomeItem?.tags ?? <String>[];
    }
  }

  Future<void> _loadUserCurrencies() async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    final UserRepository userRepository = context.read<UserRepository>();
    final UserModel? user = await userRepository.getUser(authUser.uid);

    if (user != null) {
      final List<String> allowed = <String>[];
      final String primary = user.primaryCurrency.isNotEmpty
          ? user.primaryCurrency
          : hnlCurrency;
      allowed.add(primary);

      if (user.enableDualCurrency) {
        final String secondary = primary == hnlCurrency
            ? usdCurrency
            : hnlCurrency;
        if (!allowed.contains(secondary)) {
          allowed.add(secondary);
        }
      }

      if (mounted) {
        setState(() {
          _availableCurrencies = allowed;
          if (selectedCurrency == null ||
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
      margin: EdgeInsets.all(16.0),
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
                    label: context.translate('tags'),
                    hintText: context.translate('enter_tags'),
                    initialTags: tags,
                    onChanged: (final List<String> updatedTags) {
                      setState(() {
                        tags = updatedTags;
                      });
                    },
                  ),
                  CustomLabelInput(
                    label: context.translate('income_name'),
                    hintText: context.translate('enter_income_name'),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_income_name');
                      }
                      return null;
                    },
                    controller: _nameController,
                  ),
                  CustomLabelInput(
                    label: context.translate('comment'),
                    hintText: context.translate('enter_comment'),
                    validator: (final String? value) {
                      if (value == null || value.isEmpty) {
                        return context.translate('please_enter_comment');
                      }
                      return null;
                    },
                    controller: _commentController,
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
                    keyboardType: TextInputType.numberWithOptions(
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
                    label: context.translate('date_to_receive'),
                    hintText: context.translate('enter_date_to_receive'),
                    isReadOnly: true,
                    isCalendar: true,
                    onTap: () async {
                      final CustomCalendarDialog calendar =
                          CustomCalendarDialog();
                      final DateTime? selectedDate = await calendar
                          .showDateDialog(
                            context: context,
                            dateController: _dateToReceiveController,
                          );
                      if (selectedDate != null) {
                        final String formatted = DateFormat(
                          dayMonthYearFormat,
                        ).format(selectedDate);
                        _dateToReceiveController.text = formatted;
                      }
                    },
                    validator: (final String? value) => null,
                    controller: _dateToReceiveController,
                  ),
                  SizedBox(height: 20.0),
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final String currentUid =
                                  FirebaseAuth.instance.currentUser?.uid ??
                                  emptyString;
                              final IncomeItem newItem = IncomeItem(
                                id: widget.isEdit
                                    ? widget.incomeItem!.id
                                    : DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                userId: widget.isEdit
                                    ? widget.incomeItem!.userId
                                    : currentUid,
                                name: _nameController.text,
                                comment: _commentController.text,
                                currency: selectedCurrency!,
                                createdDate: widget.isEdit
                                    ? widget.incomeItem!.createdDate
                                    : DateTime.now(),
                                amount:
                                    double.tryParse(
                                      _amountController.text.replaceAll(
                                        ',',
                                        emptyString,
                                      ),
                                    ) ??
                                    0,
                                frequency: selectedFrequency!,
                                dateToReceive: _dateToReceiveController.text,
                                status: widget.isEdit
                                    ? widget.incomeItem!.status
                                    : true,
                                tags: tags,
                              );

                              widget.onSave(newItem);
                              widget.onClose();
                            }
                          },
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
}
