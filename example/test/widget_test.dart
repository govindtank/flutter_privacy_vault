import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';
import 'package:example/main.dart';

void main() {
  tearDown(() {
    PrivacyVaultController.reset();
  });

  testWidgets('PrivacyVaultDemoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PrivacyVaultDemoApp());
    expect(find.text('flutter_privacy_vault'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });
}
