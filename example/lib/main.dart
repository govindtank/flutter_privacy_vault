import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';

void main() {
  runApp(const PrivacyVaultDemoApp());
}

class PrivacyVaultDemoApp extends StatelessWidget {
  const PrivacyVaultDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_privacy_vault — Security & Shield Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          surface: Color(0xFF18181B),
        ),
      ),
      builder: (context, child) {
        return PrivacyVault(
          config: PrivacyVaultConfig(
            enableBackgroundShield: true,
            inactivityTimeout: const Duration(seconds: 45),
            lockOnInactivity: true,
            onLocked: () =>
                debugPrint('Vault locked due to inactivity/trigger'),
            onUnlocked: () => debugPrint('Vault unlocked by user'),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const BankingDashboardScreen(),
    );
  }
}

class BankingDashboardScreen extends StatefulWidget {
  const BankingDashboardScreen({super.key});

  @override
  State<BankingDashboardScreen> createState() => _BankingDashboardScreenState();
}

class _BankingDashboardScreenState extends State<BankingDashboardScreen> {
  bool _copiedCommand = false;

  Future<void> _copyPubCommand() async {
    await Clipboard.setData(
      const ClipboardData(text: 'flutter pub add flutter_privacy_vault'),
    );
    HapticFeedback.lightImpact();
    setState(() => _copiedCommand = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCommand = false);
    });
  }

  void _simulateBackgroundShield() {
    PrivacyVaultController.isAppInBackground.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        PrivacyVaultController.isAppInBackground.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'flutter_privacy_vault',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Copy Install Button
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _copiedCommand ? Icons.check : Icons.terminal_rounded,
                    size: 14,
                    color: _copiedCommand
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copiedCommand ? 'Copied pub add!' : 'pub add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _copiedCommand
                          ? const Color(0xFF10B981)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Global Privacy Toggle Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_off_outlined,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sensitive Data Masking Mode',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: PrivacyVaultController.isDataMasked,
                        builder: (context, isMasked, _) {
                          return Switch(
                            value: isMasked,
                            activeTrackColor: const Color(0xFF10B981),
                            onChanged: (val) =>
                                PrivacyVaultController.setDataMasking(val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Card 1: Balance (Bullets style)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFF374151)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL PORTFOLIO (BULLETS MASK)',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 18,
                            ),
                            onPressed: () =>
                                PrivacyVaultController.toggleDataMasking(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      PrivacyMask(
                        style: MaskingStyle.bullets,
                        child: const Text(
                          '\$142,850.75',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '+12.4% this month',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Card 2: Crypto Holdings (Blur style)
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.currency_bitcoin,
                          color: Color(0xFFF59E0B),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bitcoin Vault (Blur Mask)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            PrivacyMask(
                              style: MaskingStyle.blur,
                              child: const Text(
                                '3.4281 BTC (≈ \$228,500.00)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Card 3: Account Number (Redacted style)
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.credit_card,
                        color: Color(0xFF60A5FA),
                        size: 22,
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Debit Card Number (Redacted Mask)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            PrivacyMask(
                              style: MaskingStyle.redacted,
                              child: const Text(
                                '4820 9182 4410 9921',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),

                // Interactive Simulator Actions
                const Text(
                  'SECURITY SIMULATORS',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => PrivacyVaultController.lock(),
                      icon: const Icon(Icons.lock_outline, size: 16),
                      label: const Text('Lock Vault Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _simulateBackgroundShield,
                      icon: const Icon(Icons.blur_on, size: 16),
                      label: const Text('Test App-Switcher Shield (3s)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
