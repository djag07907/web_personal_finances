import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/commons/export/csv_export_service.dart';

void main() {
  group('CsvExportService Tests', () {
    test('escapes values containing commas, quotes, and newlines', () {
      expect(CsvExportService.escapeCell('Normal Text'), equals('Normal Text'));
      expect(
        CsvExportService.escapeCell('Apples, Bananas'),
        equals('"Apples, Bananas"'),
      );
      expect(
        CsvExportService.escapeCell('He said "Hello"'),
        equals('"He said ""Hello"""'),
      );
      expect(
        CsvExportService.escapeCell('Line 1\nLine 2'),
        equals('"Line 1\nLine 2"'),
      );
    });

    test('toCsvRow joins multiple cells with commas', () {
      final List<dynamic> cells = <dynamic>[
        '101',
        'Grocery, Market',
        142.50,
        'USD',
      ];
      final String row = CsvExportService.toCsvRow(cells);

      expect(row, equals('101,"Grocery, Market",142.5,USD'));
    });
  });
}
