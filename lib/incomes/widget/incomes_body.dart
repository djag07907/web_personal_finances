import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/incomes/widget/incomes_list_table.dart';

class IncomesBody extends StatefulWidget {
  const IncomesBody({super.key});

  @override
  State<IncomesBody> createState() => _IncomesBodyState();
}

class _IncomesBodyState extends State<IncomesBody> {
  final List<IncomeItem> _incomeItems = <IncomeItem>[
    IncomeItem(
      name: 'Salary',
      comment: 'Monthly Salary',
      currency: 'USD',
      amount: 3000,
    ),
    IncomeItem(
      name: 'Freelancing',
      comment: 'Web Development',
      currency: 'USD',
      amount: 1500,
    ),
  ];

  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomCardBody(
          isMain: false,
          isMenu: true,
          title: context.translate('incomes'),
          body: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: CustomButton(
                  text: 'Add Income',
                  isPrimary: true,
                  onPressed: _addIncome,
                ),
              ),
              Expanded(
                child: IncomeList(
                  incomeItems: _incomeItems,
                  onEdit: _editIncome,
                  onRemove: _removeIncome,
                ),
              ),
              _buildPagination(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        Text('Page ${_currentPage + 1}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: (_currentPage + 1) * _itemsPerPage < _incomeItems.length
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  void _addIncome() {
    // Logic to open the right side menu and add income
    // You can implement a form dialog or a side menu here
    showSnackbar(context, 'Add Income functionality not implemented yet.');
  }

  void _editIncome(final IncomeItem item) {
    // Logic to open the right side menu with the selected income item data
    showSnackbar(context, 'Edit Income functionality not implemented yet.');
  }

  void _removeIncome(final IncomeItem item) async {
    final bool? confirmed = await showConfirmationDialog(
      context,
      'Confirm Removal',
      'Are you sure you want to remove this income?',
    );
    if (confirmed == true) {
      setState(() {
        _incomeItems.remove(item);
      });
      showSnackbar(context, 'Income removed successfully.');
    }
  }
}
