import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/themes.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';

class Menu extends StatelessWidget {
  final String userInitials;
  final bool isClosed;

  const Menu({
    super.key,
    required this.userInitials,
    this.isClosed = false,
  });

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: LightColors.background,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            height: isClosed ? 500 : 1000,
            width: isClosed ? 100 : 250,
            child: Column(
              children: [
                CustomDrawerHeader(
                  userInitials: userInitials,
                  isClosed: isClosed,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.home,
                          title: isClosed ? emptyString : 'Home',
                          onTap: () {
                            context.go(homeRoute);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.attach_money,
                          title: isClosed ? emptyString : 'Incomes',
                          onTap: () {
                            context.go(incomesRoute);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.explicit,
                          title: isClosed ? emptyString : 'Fixed Expenses',
                          onTap: () {
                            context.go(expensesRoute);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.account_balance,
                          title: isClosed ? emptyString : 'Accounts to Pay',
                          onTap: () {
                            context.go(accountsToPayRoute);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: isClosed ? emptyString : 'Accounts Receivable',
                          onTap: () {
                            context.go(accountsReceivableRoute);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: isClosed
                      ? ListTile(
                          title: Icon(
                            Icons.logout,
                            color: lightTheme.primaryColor,
                          ),
                          onTap: () async {
                            await RepositoryProvider.of<AuthRepository>(context)
                                .signOut();
                            context.go(rootRoute);
                          },
                        )
                      : ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: lightTheme.primaryColor,
                          ),
                          title: Text(isClosed ? emptyString : 'Logout'),
                          onTap: () async {
                            await RepositoryProvider.of<AuthRepository>(context)
                                .signOut();
                            context.go(rootRoute);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    String? title,
    required VoidCallback onTap,
  }) {
    return isClosed
        ? SizedBox(
            height: isClosed ? 55 : null,
            child: ListTile(
              title: Icon(
                icon,
                color: lightTheme.primaryColor,
              ),
              onTap: onTap,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              leading: Icon(
                icon,
                color: lightTheme.primaryColor,
              ),
              title: Text(title!),
              onTap: onTap,
            ),
          );
  }
}

class CustomDrawerHeader extends StatelessWidget {
  final String userInitials;
  final bool isClosed;

  const CustomDrawerHeader({
    super.key,
    required this.userInitials,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: isClosed ? 90 : 160,
          decoration: BoxDecoration(
            color: lightTheme.primaryColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: lightTheme.primaryColor,
                  foregroundColor: white,
                  radius: isClosed ? 20 : 30,
                  child: Text(
                    userInitials,
                    style: TextStyle(
                      color: white,
                      fontSize: isClosed ? 14 : 24,
                    ),
                  ),
                ),
              ),
              if (!isClosed) ...[
                SizedBox(height: 15),
                Text(
                  'Bienvenido, Daniel Alvarez',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
