import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/legal/privacy_screen.dart';
import 'package:web_personal_finances/legal/terms_screen.dart';

void main() {
  group('Legal Screens Widget Tests', () {
    testWidgets('renders TermsScreen with expected headers', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      expect(find.text('Terms of Service'), findsWidgets);
      expect(
        find.text('Zero-Knowledge Security Model & Cryptographic Custody'),
        findsOneWidget,
      );
      expect(
        find.text('Financial Information & Non-Advisory Disclaimer'),
        findsOneWidget,
      );
      expect(
        find.text('Dispute Resolution, Binding Arbitration & Class Action Waiver'),
        findsOneWidget,
      );
    });

    testWidgets('renders PrivacyScreen with Zero-Knowledge highlights', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyScreen(),
        ),
      );

      expect(
        find.text('Privacy Policy & Zero-Knowledge Architecture'),
        findsOneWidget,
      );
      expect(find.text('Zero-Knowledge Cryptographic Privacy'), findsOneWidget);
      expect(
        find.text('Cryptographic Engine & Key Hierarchy'),
        findsOneWidget,
      );
      expect(
        find.text('Data Classification & Cloud Storage Partitioning'),
        findsOneWidget,
      );
      expect(
        find.text('European Privacy Rights (GDPR & UK GDPR)'),
        findsOneWidget,
      );
    });
  });
}

