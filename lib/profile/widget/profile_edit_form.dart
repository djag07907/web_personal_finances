import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    required this.user,
    required this.isDark,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final UserModel user;
  final bool isDark;
  final ValueChanged<UserModel> onSave;
  final VoidCallback onCancel;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _professionController;
  late final TextEditingController _birthDateController;
  late String _selectedCurrency;
  late bool _enableDualCurrency;

  final List<String> _currencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _professionController = TextEditingController(text: widget.user.profession);
    _birthDateController = TextEditingController(text: widget.user.birthDate);
    _selectedCurrency = widget.user.primaryCurrency.isNotEmpty
        ? widget.user.primaryCurrency
        : hnlCurrency;
    _enableDualCurrency = widget.user.enableDualCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final UserModel updatedUser = widget.user.copyWith(
      fullName: _nameController.text.trim(),
      profession: _professionController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      primaryCurrency: _selectedCurrency,
      enableDualCurrency: _enableDualCurrency,
    );

    widget.onSave(updatedUser);
  }

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? DarkColors.border : Colors.grey.shade300,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Edit Account Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            CustomLabelInput(
              label: 'Full Name *',
              hintText: 'Enter full name',
              validator: (final String? val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Full name cannot be empty';
                }
                return null;
              },
              controller: _nameController,
            ),
            CustomLabelInput(
              label: 'Profession',
              hintText: 'Enter profession or job title',
              validator: (final String? val) => null,
              controller: _professionController,
            ),
            CustomLabelInput(
              label: 'Birth Date',
              hintText: 'Select birth date',
              isCalendar: true,
              isReadOnly: true,
              validator: (final String? val) => null,
              controller: _birthDateController,
              onTap: () {
                CustomCalendarDialog().showDateDialog(
                  context: context,
                  dateController: _birthDateController,
                );
              },
            ),
            CustomLabelSelector(
              label: 'Primary Currency',
              hintText: 'Select primary currency',
              validator: (final String? val) => null,
              selectedValue: _selectedCurrency,
              items: _currencies,
              onChanged: (final String? val) {
                if (val != null) {
                  setState(() {
                    _selectedCurrency = val;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable Dual Currency Mode (HNL & USD)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Simultaneously manage transactions in Honduran Lempiras (L.) and US Dollars (\$)',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              value: _enableDualCurrency,
              activeThumbColor: LightColors.primary,
              onChanged: (final bool val) {
                setState(() {
                  _enableDualCurrency = val;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    onPressed: widget.onCancel,
                    isPrimary: false,
                    text: 'Cancel',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: CustomButton(
                    onPressed: _submit,
                    isPrimary: true,
                    text: 'Save Changes',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
