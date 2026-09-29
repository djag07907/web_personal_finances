import 'package:flutter/material.dart';
import 'package:web_personal_finances/profile/widget/profile_info_card.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileDetailsView extends StatelessWidget {
  const ProfileDetailsView({
    required this.user,
    required this.isDark,
    super.key,
  });

  final UserModel user;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
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
              child: ProfileInfoCard(
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
              child: ProfileInfoCard(
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
              child: ProfileInfoCard(
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
              child: ProfileInfoCard(
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
}
