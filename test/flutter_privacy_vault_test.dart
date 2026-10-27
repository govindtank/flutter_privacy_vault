import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';

void main() {
  setUp(() {
    PrivacyVaultController.reset();
  });

  group('PrivacyVaultController logic', () {
    test('lock and unlock transitions state', () {
      expect(PrivacyVaultController.isLocked.value, isFalse);

      PrivacyVaultController.lock();
      expect(PrivacyVaultController.isLocked.value, isTrue);

      PrivacyVaultController.unlock();
      expect(PrivacyVaultController.isLocked.value, isFalse);
    });

    test('toggleDataMasking flips masked state', () {
      expect(PrivacyVaultController.isDataMasked.value, isFalse);

      PrivacyVaultController.toggleDataMasking();
      expect(PrivacyVaultController.isDataMasked.value, isTrue);

      PrivacyVaultController.setDataMasking(false);
      expect(PrivacyVaultController.isDataMasked.value, isFalse);
    });
  });

  group('PrivacyMask Widget Tests', () {
    testWidgets('renders plain text when unmasked, bullets when masked',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrivacyMask(
              child: Text('\$45,200.00'),
            ),
          ),
        ),
      );

      expect(find.text('\$45,200.00'), findsOneWidget);
      expect(find.text('••••••••'), findsNothing);

      PrivacyVaultController.setDataMasking(true);
      await tester.pump();

      expect(find.text('\$45,200.00'), findsNothing);
      expect(find.text('••••••••'), findsOneWidget);
    });
  });

  group('PrivacyVault Widget Tests', () {
    testWidgets('renders child content and shows lock screen when locked',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrivacyVault(
              child: Text('Protected Bank Account Details'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Bank Account Details'), findsOneWidget);
      expect(find.text('App Vault Locked'), findsNothing);

      PrivacyVaultController.lock();
      await tester.pump();

      expect(find.text('App Vault Locked'), findsOneWidget);
      expect(find.text('Unlock with Biometrics'), findsOneWidget);

      await tester.tap(find.text('Unlock with Biometrics'));
      await tester.pump();

      expect(find.text('App Vault Locked'), findsNothing);
      expect(find.text('Protected Bank Account Details'), findsOneWidget);
    });
  });
}
