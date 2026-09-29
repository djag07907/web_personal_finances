import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, required this.isDark, super.key});

  final UserModel user;
  final bool isDark;

  @override
  Widget build(final BuildContext context) {
    final String initials = user.fullName.isNotEmpty
        ? user.fullName
              .trim()
              .split(' ')
              .map((final String e) => e.isNotEmpty ? e[0] : emptyString)
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
}
