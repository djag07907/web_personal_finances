import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _professionController;
  late final TextEditingController _birthDateController;
  String _selectedCurrency = hnlCurrency;
  bool _enableDualCurrency = false;
  bool _isEditing = false;
  bool _isSaving = false;

  final List<String> _currencies = <String>[hnlCurrency, usdCurrency];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _professionController = TextEditingController();
    _birthDateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _populateEditForm(final UserModel user) {
    _nameController.text = user.fullName;
    _professionController.text = user.profession;
    _birthDateController.text = user.birthDate;
    _selectedCurrency = user.primaryCurrency.isNotEmpty
        ? user.primaryCurrency
        : hnlCurrency;
    _enableDualCurrency = user.enableDualCurrency;
  }

  Future<void> _saveProfile(final UserModel currentUser) async {
    if (!_editFormKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final UserModel updatedUser = currentUser.copyWith(
        fullName: _nameController.text.trim(),
        profession: _professionController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        primaryCurrency: _selectedCurrency,
        enableDualCurrency: _enableDualCurrency,
      );

      final UserRepository userRepository = context.read<UserRepository>();
      await userRepository.saveUser(updatedUser);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        showSnackbar(context, context.translate('income_saved_successfully'));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        showSnackbar(context, e.toString());
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final User? authUser = FirebaseAuth.instance.currentUser;
    final String uid = authUser?.uid ?? emptyString;
    final UserRepository userRepository = context.read<UserRepository>();

    return StreamBuilder<UserModel?>(
      stream: userRepository.streamUser(uid),
      builder:
          (
            final BuildContext context,
            final AsyncSnapshot<UserModel?> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }

            final UserModel user =
                snapshot.data ??
                UserModel(
                  uid: uid,
                  email: authUser?.email ?? emptyString,
                  fullName: authUser?.displayName ?? emptyString,
                );

            return Stack(
              children: <Widget>[
                CustomCardBody(
                  isMain: false,
                  isMenu: true,
                  title: context.translate('profile'),
                  description:
                      'Manage your personal account details and preferences',
                  buttonText: _isEditing ? 'Cancel Edit' : 'Edit Profile',
                  buttonIsPrimary: !_isEditing,
                  onButtonPressed: () {
                    setState(() {
                      if (!_isEditing) {
                        _populateEditForm(user);
                      }
                      _isEditing = !_isEditing;
                    });
                  },
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildHeaderCard(context, user, isDark),
                          const SizedBox(height: 24),
                          if (_isEditing)
                            _buildEditForm(context, user, isDark)
                          else
                            _buildDetailsGrid(context, user, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isSaving) const Loader(),
              ],
            );
          },
    );
  }

  Widget _buildHeaderCard(
    final BuildContext context,
    final UserModel user,
    final bool isDark,
  ) {
    final String initials = user.fullName.isNotEmpty
        ? user.fullName
              .trim()
              .split(' ')
              .map((final String e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 40,
            backgroundColor: LightColors.primary,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Valued User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.profession.isNotEmpty
                      ? user.profession
                      : 'Personal Finances User',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(
    final BuildContext context,
    final UserModel user,
    final bool isDark,
  ) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth > 700
            ? (constraints.maxWidth - 20) / 2
            : constraints.maxWidth;

        final String currencyDisplay = user.enableDualCurrency
            ? '${user.primaryCurrency} (Dual Mode HNL & USD Enabled)'
            : user.primaryCurrency;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              child: _buildInfoCard(
                isDark: isDark,
                title: 'Full Name',
                value: user.fullName.isNotEmpty
                    ? user.fullName
                    : 'Not specified',
                icon: Icons.person_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildInfoCard(
                isDark: isDark,
                title: 'Profession / Occupation',
                value: user.profession.isNotEmpty
                    ? user.profession
                    : 'Not specified',
                icon: Icons.work_outline,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildInfoCard(
                isDark: isDark,
                title: 'Birth Date',
                value: user.birthDate.isNotEmpty
                    ? user.birthDate
                    : 'Not specified',
                icon: Icons.cake_outlined,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildInfoCard(
                isDark: isDark,
                title: 'Primary & Supported Currencies',
                value: currencyDisplay,
                icon: Icons.monetization_on_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required final bool isDark,
    required final String title,
    required final String value,
    required final IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LightColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: LightColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(
    final BuildContext context,
    final UserModel user,
    final bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : Colors.grey.shade300,
        ),
      ),
      child: Form(
        key: _editFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Edit Account Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
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
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Simultaneously manage transactions in Honduran Lempiras (L.) and US Dollars (\$)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
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
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    isPrimary: false,
                    text: 'Cancel',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: CustomButton(
                    onPressed: () => _saveProfile(user),
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
