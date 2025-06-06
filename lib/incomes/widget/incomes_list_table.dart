import 'package:flutter/material.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';

class IncomeList extends StatelessWidget {
  final List<IncomeItem> incomeItems;
  final Function(IncomeItem) onEdit;
  final Function(IncomeItem) onRemove;

  const IncomeList({
    super.key,
    required this.incomeItems,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(final BuildContext context) {
    return DataTable(
      columns: <DataColumn>[
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Comment')),
        DataColumn(label: Text('Currency')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Actions')),
      ],
      rows: incomeItems.map((final IncomeItem item) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(item.name)),
            DataCell(Text(item.comment)),
            DataCell(Text(item.currency)),
            DataCell(Text(item.amount.toString())),
            DataCell(
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      // No action needed here; the PopupMenuButton will handle it.
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (final String value) {
                      if (value == 'edit') {
                        onEdit(item);
                      } else if (value == 'remove') {
                        onRemove(item);
                      }
                    },
                    itemBuilder: (final BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
