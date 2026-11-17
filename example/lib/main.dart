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
      title:
          'flutter_privacy_vault — Indian Bank-Grade PII Masking & Privacy Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF111827),
        ),
      ),
      builder: (context, child) {
        return PrivacyVault(
          config: PrivacyVaultConfig(
            enableBackgroundShield: true,
            inactivityTimeout: const Duration(seconds: 45),
            lockOnInactivity: true,
            maskSensitiveDataByDefault: true,
            onLocked: () =>
                debugPrint('Vault locked due to inactivity/trigger'),
            onUnlocked: () => debugPrint('Vault unlocked by user'),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const BankingShowcaseScreen(),
    );
  }
}

class BankingShowcaseScreen extends StatefulWidget {
  const BankingShowcaseScreen({super.key});

  @override
  State<BankingShowcaseScreen> createState() => _BankingShowcaseScreenState();
}

class _BankingShowcaseScreenState extends State<BankingShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _copiedCommand = false;

  // Mobile Masking Customization State
  int _mobileLeading = 0;
  int _mobileTrailing = 4;
  String _mobileMaskChar = 'X';
  bool _mobilePreserveCode = true;

  // Email Masking Customization State
  int _emailLeading = 1;
  int _emailTrailing = 1;
  String _emailMaskChar = '*';
  bool _emailMaskDomain = false;

  // Birthdate Masking Customization State
  DateMaskStyle _dateStyle = DateMaskStyle.dayAndMonth;
  String _dateMaskChar = 'X';

  // Address Masking Customization State
  AddressMaskLevel _addressLevel = AddressMaskLevel.streetAndPremise;
  int _addressPinDigits = 3;
  String _addressMaskChar = '*';

  // General Masking Customization State
  int _genStart = 0;
  int _genEnd = 4;
  String _genMaskChar = 'X';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'flutter_privacy_vault',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Bank-Grade PII Masking & Privacy Shield',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(40),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.3.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(
                icon: Icon(Icons.password_rounded),
                text: 'Bank PII Masking Hub'),
            Tab(
                icon: Icon(Icons.account_balance_wallet_rounded),
                text: 'Vault & Shield Controls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMaskingHubTab(),
          _buildVaultControlsTab(),
        ],
      ),
    );
  }

  Widget _buildMaskingHubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner
              _buildTopHeroBanner(),
              const SizedBox(height: 20),

              // Global Masking Switch
              _buildGlobalMaskingBar(),
              const SizedBox(height: 24),

              // 1. Mobile Number Masking Card
              _buildMobileMaskingSection(),
              const SizedBox(height: 20),

              // 2. Email Masking Card
              _buildEmailMaskingSection(),
              const SizedBox(height: 20),

              // 3. Birthdate Masking Card
              _buildBirthdateMaskingSection(),
              const SizedBox(height: 20),

              // 4. Address Masking Card
              _buildAddressMaskingSection(),
              const SizedBox(height: 20),

              // 5. General & Indian Banking Presets
              _buildGeneralMaskingSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultControlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGlobalMaskingBar(),
              const SizedBox(height: 24),

              // Balances card with PrivacyMask
              Container(
                padding: const EdgeInsets.all(22.0),
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
                          'TOTAL PORTFOLIO (PRIVACY MASK)',
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
                            color: Color(0xFF10B981),
                          ),
                          onPressed: () =>
                              PrivacyVaultController.toggleDataMasking(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    PrivacyMask(
                      style: MaskingStyle.bullets,
                      allowTapToggle: true,
                      child: const Text(
                        '₹ 14,82,500.00',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Tapping or toggling reveals account balance. Auto-obscures on inactivity.',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Simulators
              const Text(
                'SECURITY SIMULATORS',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => PrivacyVaultController.lock(),
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('Lock Vault (PIN Pad)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _simulateBackgroundShield,
                      icon: const Icon(Icons.visibility_off_outlined, size: 18),
                      label: const Text('Test App-Switcher Shield'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        side: const BorderSide(color: Color(0xFF374151)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_user_rounded,
                    color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indian Bank-Grade PII Masking Engine',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      'Inspired by HDFC, SBI, ICICI, Axis, Zerodha & UIDAI privacy best practices',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: Row(
                children: [
                  const Text(
                    '\$ flutter pub add flutter_privacy_vault',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _copiedCommand ? Icons.check_circle : Icons.copy_rounded,
                    size: 16,
                    color:
                        _copiedCommand ? const Color(0xFF34D399) : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalMaskingBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyVaultController.isDataMasked,
      builder: (context, isMasked, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMasked
                ? const Color(0xFF064E3B).withAlpha(70)
                : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isMasked ? const Color(0xFF10B981) : const Color(0xFF374151),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isMasked ? Icons.shield_rounded : Icons.shield_outlined,
                color: isMasked ? const Color(0xFF10B981) : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMasked
                          ? 'Global PII Masking: ACTIVE'
                          : 'Global PII Masking: INACTIVE (Full PII Revealed)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color:
                            isMasked ? const Color(0xFF34D399) : Colors.white,
                      ),
                    ),
                    const Text(
                      'Toggles masking globally across all PrivacyValue and PrivacyMask widgets.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isMasked,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => PrivacyVaultController.setDataMasking(val),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Mobile Number Masking Section
  Widget _buildMobileMaskingSection() {
    return _buildFeatureCard(
      title: '1. Mobile Number Masking',
      subtitle:
          'HDFC/SBI style: country code prefix, masked middle, visible trailing digits',
      icon: Icons.phone_android_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrivacyValue(
                    value: '+91 9876543210',
                    label: 'Registered Indian Mobile',
                    type: PrivacyValueType.mobile,
                    visibleLeading: _mobileLeading,
                    visibleTrailing: _mobileTrailing,
                    maskChar: _mobileMaskChar,
                    showEyeToggle: true,
                    showCopyButton: true,
                    showBadge: true,
                    autoObscureDuration: const Duration(seconds: 5),
                    customMasker: (raw) => PrivacyMasker.maskMobile(
                      raw,
                      visibleLeading: _mobileLeading,
                      visibleTrailing: _mobileTrailing,
                      maskChar: _mobileMaskChar,
                      preserveCountryCode: _mobilePreserveCode,
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF67E8F9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildOptionChip(
                label: 'Mask Char',
                child: DropdownButton<String>(
                  value: _mobileMaskChar,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'X', child: Text("'X' (SBI/HDFC)")),
                    DropdownMenuItem(value: '*', child: Text("'*' (Standard)")),
                    DropdownMenuItem(value: '•', child: Text("'•' (Bullets)")),
                  ],
                  onChanged: (v) => setState(() => _mobileMaskChar = v!),
                ),
              ),
              _buildOptionChip(
                label: 'Visible Leading: $_mobileLeading',
                child: Slider(
                  value: _mobileLeading.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _mobileLeading = v.toInt()),
                ),
              ),
              _buildOptionChip(
                label: 'Visible Trailing: $_mobileTrailing',
                child: Slider(
                  value: _mobileTrailing.toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _mobileTrailing = v.toInt()),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Keep Country Code:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Switch(
                    value: _mobilePreserveCode,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (val) =>
                        setState(() => _mobilePreserveCode = val),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Email Masking Section
  Widget _buildEmailMaskingSection() {
    return _buildFeatureCard(
      title: '2. Email Masking',
      subtitle:
          'Preserves first/last username characters and optionally shields domain',
      icon: Icons.alternate_email_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrivacyValue(
                    value: 'govind.tank@hdfcbank.com',
                    label: 'Primary Communication Email',
                    type: PrivacyValueType.email,
                    visibleLeading: _emailLeading,
                    visibleTrailing: _emailTrailing,
                    maskChar: _emailMaskChar,
                    showEyeToggle: true,
                    showCopyButton: true,
                    showBadge: true,
                    autoObscureDuration: const Duration(seconds: 5),
                    customMasker: (raw) => PrivacyMasker.maskEmail(
                      raw,
                      visibleLeading: _emailLeading,
                      visibleTrailing: _emailTrailing,
                      maskChar: _emailMaskChar,
                      maskDomain: _emailMaskDomain,
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFCD34D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildOptionChip(
                label: 'Mask Char',
                child: DropdownButton<String>(
                  value: _emailMaskChar,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: '*', child: Text("'*' (ICICI/SBI)")),
                    DropdownMenuItem(value: 'X', child: Text("'X' (Axis)")),
                    DropdownMenuItem(value: '•', child: Text("'•' (Bullets)")),
                  ],
                  onChanged: (v) => setState(() => _emailMaskChar = v!),
                ),
              ),
              _buildOptionChip(
                label: 'Leading: $_emailLeading',
                child: Slider(
                  value: _emailLeading.toDouble(),
                  min: 1,
                  max: 3,
                  divisions: 2,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _emailLeading = v.toInt()),
                ),
              ),
              _buildOptionChip(
                label: 'Trailing: $_emailTrailing',
                child: Slider(
                  value: _emailTrailing.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _emailTrailing = v.toInt()),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mask Domain:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Switch(
                    value: _emailMaskDomain,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _emailMaskDomain = val),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Birthdate Masking Section
  Widget _buildBirthdateMaskingSection() {
    return _buildFeatureCard(
      title: '3. Birthdate Masking',
      subtitle:
          'Indian KYC Age Verification standard (Day/Month masked, Year visible)',
      icon: Icons.cake_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrivacyValue.birthdate(
                    value: '15/08/1995',
                    label: 'Date of Birth (KYC Verification)',
                    dateStyle: _dateStyle,
                    maskChar: _dateMaskChar,
                    showEyeToggle: true,
                    showCopyButton: true,
                    showBadge: true,
                    autoObscureDuration: const Duration(seconds: 5),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA7F3D0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildOptionChip(
                label: 'Mask Mode',
                child: DropdownButton<DateMaskStyle>(
                  value: _dateStyle,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: DateMaskStyle.dayAndMonth,
                      child: Text('dayAndMonth (XX/XX/1995)'),
                    ),
                    DropdownMenuItem(
                      value: DateMaskStyle.yearOnly,
                      child: Text('yearOnly (15/08/XXXX)'),
                    ),
                    DropdownMenuItem(
                      value: DateMaskStyle.dayAndYear,
                      child: Text('dayAndYear (XX/08/XXXX)'),
                    ),
                    DropdownMenuItem(
                      value: DateMaskStyle.full,
                      child: Text('full (XX/XX/XXXX)'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _dateStyle = v!),
                ),
              ),
              _buildOptionChip(
                label: 'Mask Char',
                child: DropdownButton<String>(
                  value: _dateMaskChar,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                        value: 'X', child: Text("'X' (Official KYC)")),
                    DropdownMenuItem(value: '*', child: Text("'*' (Asterisk)")),
                    DropdownMenuItem(value: '•', child: Text("'•' (Bullet)")),
                  ],
                  onChanged: (v) => setState(() => _dateMaskChar = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Address Masking Section
  Widget _buildAddressMaskingSection() {
    return _buildFeatureCard(
      title: '4. Address Masking',
      subtitle:
          'Conceals premise/street numbers while preserving locality, city, state & partial PIN',
      icon: Icons.location_on_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrivacyValue.address(
                    value:
                        'Flat 402, Lotus Residency, MG Road, Indiranagar, Bengaluru, Karnataka 560038',
                    label: 'Communication Address',
                    addressLevel: _addressLevel,
                    visiblePinDigits: _addressPinDigits,
                    maskChar: _addressMaskChar,
                    showEyeToggle: true,
                    showCopyButton: true,
                    showBadge: true,
                    autoObscureDuration: const Duration(seconds: 5),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDDD6FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildOptionChip(
                label: 'Mask Level',
                child: DropdownButton<AddressMaskLevel>(
                  value: _addressLevel,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: AddressMaskLevel.premiseOnly,
                      child: Text('premiseOnly (Flat ***)'),
                    ),
                    DropdownMenuItem(
                      value: AddressMaskLevel.streetAndPremise,
                      child: Text('streetAndPremise (Recommended)'),
                    ),
                    DropdownMenuItem(
                      value: AddressMaskLevel.strict,
                      child: Text('strict (City & State only)'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _addressLevel = v!),
                ),
              ),
              _buildOptionChip(
                label: 'PIN Visible Digits: $_addressPinDigits',
                child: Slider(
                  value: _addressPinDigits.toDouble(),
                  min: 0,
                  max: 6,
                  divisions: 6,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) =>
                      setState(() => _addressPinDigits = v.toInt()),
                ),
              ),
              _buildOptionChip(
                label: 'Mask Char',
                child: DropdownButton<String>(
                  value: _addressMaskChar,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '*', child: Text("'*' (Standard)")),
                    DropdownMenuItem(value: 'X', child: Text("'X' (Letter)")),
                    DropdownMenuItem(value: '•', child: Text("'•' (Bullet)")),
                  ],
                  onChanged: (v) => setState(() => _addressMaskChar = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. General & Indian Banking Presets
  Widget _buildGeneralMaskingSection() {
    return _buildFeatureCard(
      title: '5. General Masking & Indian Banking Presets',
      subtitle:
          'UIDAI Aadhaar, IT PAN, Bank Account & Payment Cards with full customization',
      icon: Icons.fingerprint_rounded,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aadhaar Card
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const PrivacyValue(
              value: '5432 9876 1234',
              label: 'UIDAI Aadhaar Number (XXXX XXXX 1234)',
              type: PrivacyValueType.aadhaar,
              showEyeToggle: true,
              showCopyButton: true,
              showBadge: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF472B6),
              ),
            ),
          ),

          // PAN Card
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const PrivacyValue(
              value: 'ABCDE1234F',
              label: 'Income Tax PAN Card (XXXXX1234X)',
              type: PrivacyValueType.pan,
              showEyeToggle: true,
              showCopyButton: true,
              showBadge: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF38BDF8),
              ),
            ),
          ),

          // Bank Account Number
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const PrivacyValue(
              value: '50100234589211',
              label: 'HDFC Savings Account Number',
              type: PrivacyValueType.bankAccount,
              showEyeToggle: true,
              showCopyButton: true,
              showBadge: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF34D399),
              ),
            ),
          ),

          // General String Customizer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: PrivacyValue.general(
              value: 'AUTH_SESSION_TOKEN_89214710',
              label: 'General Custom String Masker',
              visibleLeading: _genStart,
              visibleTrailing: _genEnd,
              maskChar: _genMaskChar,
              showEyeToggle: true,
              showCopyButton: true,
              showBadge: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildOptionChip(
                label: 'Leading: $_genStart',
                child: Slider(
                  value: _genStart.toDouble(),
                  min: 0,
                  max: 6,
                  divisions: 6,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _genStart = v.toInt()),
                ),
              ),
              _buildOptionChip(
                label: 'Trailing: $_genEnd',
                child: Slider(
                  value: _genEnd.toDouble(),
                  min: 0,
                  max: 8,
                  divisions: 8,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (v) => setState(() => _genEnd = v.toInt()),
                ),
              ),
              _buildOptionChip(
                label: 'Mask Char',
                child: DropdownButton<String>(
                  value: _genMaskChar,
                  dropdownColor: const Color(0xFF1E293B),
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'X', child: Text("'X' (Letter)")),
                    DropdownMenuItem(value: '*', child: Text("'*' (Asterisk)")),
                    DropdownMenuItem(value: '•', child: Text("'•' (Bullet)")),
                  ],
                  onChanged: (v) => setState(() => _genMaskChar = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildOptionChip({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: child,
          ),
        ],
      ),
    );
  }
}
