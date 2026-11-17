import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';

void main() {
  setUp(() {
    PrivacyVaultController.reset();
  });

  group('PrivacyValue Widget Tests', () {
    testWidgets('renders masked mobile value when global masking is active',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrivacyValue.mobile(
              value: '+91 9876543210',
              label: 'Registered Mobile',
            ),
          ),
        ),
      );

      // Initially global masking is false
      expect(find.text('+91 9876543210'), findsOneWidget);
      expect(find.text('Registered Mobile'), findsOneWidget);

      // Turn on global masking
      PrivacyVaultController.setDataMasking(true);
      await tester.pump();

      expect(find.text('+91 9876543210'), findsNothing);
      expect(find.text('+91 XXXXXX3210'), findsOneWidget);
    });

    testWidgets('eye toggle button reveals and hides individual value',
        (tester) async {
      PrivacyVaultController.setDataMasking(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrivacyValue.email(
              value: 'govind@example.com',
              showEyeToggle: true,
            ),
          ),
        ),
      );

      expect(find.text('g****d@example.com'), findsOneWidget);
      expect(find.text('govind@example.com'), findsNothing);

      // Tap the eye icon to reveal
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(find.text('govind@example.com'), findsOneWidget);
      expect(find.text('g****d@example.com'), findsNothing);

      // Tap again to hide
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(find.text('g****d@example.com'), findsOneWidget);
    });

    testWidgets('birthdate masking with DateMaskStyle renders properly',
        (tester) async {
      PrivacyVaultController.setDataMasking(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrivacyValue.birthdate(
              value: '15/08/1995',
              dateStyle: DateMaskStyle.dayAndMonth,
            ),
          ),
        ),
      );

      expect(find.text('XX/XX/1995'), findsOneWidget);
    });

    testWidgets('auto-obscure timer automatically hides revealed value',
        (tester) async {
      PrivacyVaultController.setDataMasking(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrivacyValue(
              value: 'SECRET_PAYMENT_PIN',
              autoObscureDuration: Duration(seconds: 2),
            ),
          ),
        ),
      );

      expect(find.text('XXXXXX_XXXXXXX_PIN'), findsOneWidget);

      // Reveal
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();
      expect(find.text('SECRET_PAYMENT_PIN'), findsOneWidget);

      // Advance time past autoObscureDuration
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('XXXXXX_XXXXXXX_PIN'), findsOneWidget);
    });
  });
}
