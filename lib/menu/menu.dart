import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/repositories/firebase_auth_repository.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/themes.dart';

class Menu extends StatelessWidget {
  final String userInitials;
  const Menu({
    super.key,
    required this.userInitials,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
              ),
              child: Text(
                'Bienvenido, Daniel Alvarez',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: white,
                ),
              ),
            ),
            accountEmail: null,
            decoration: BoxDecoration(
              color: lightTheme.primaryColor,
            ),
            currentAccountPicture: Container(
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
                radius: 30,
                child: Text(
                  userInitials,
                  style: TextStyle(
                    color: white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.attach_money,
                    title: 'Incomes',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/incomes');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.explicit,
                    title: 'Fixed Expenses',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/fixed-expenses',
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance,
                    title: 'Accounts to Pay',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounts-to-pay',
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Accounts Receivable',
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/accounts-receivable',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: lightTheme.primaryColor,
              ),
              title: const Text('Logout'),
              onTap: () async {
                await RepositoryProvider.of<AuthRepository>(context).signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: lightTheme.primaryColor,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
