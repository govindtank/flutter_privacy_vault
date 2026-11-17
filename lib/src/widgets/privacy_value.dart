import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/privacy_vault_controller.dart';
import '../masking/privacy_masker.dart';

/// Predefined masking types for sensitive banking and PII data.
enum PrivacyValueType {
  /// Mobile phone number (+91 ******1234 or XXXXXX1234).
  mobile,

  /// Email address (g****d@example.com).
  email,

  /// Date of birth (XX/XX/1995 or 15/08/XXXX).
  birthdate,

  /// Physical postal/street address.
  address,

  /// General text/ID string masking.
  general,

  /// Indian Aadhaar Card (XXXX XXXX 1234).
  aadhaar,

  /// Indian PAN Card (XXXXX1234X).
  pan,

  /// Bank account number (XXXXXXXX1234).
  bankAccount,

  /// Debit/Credit card (•••• •••• •••• 1234).
  card,
}

/// A bank-grade Flutter widget for rendering sensitive personal and financial data
/// with built-in masking, interactive eye reveal toggle, timed auto-reobscure,
/// and secure copy capabilities.
class PrivacyValue extends StatefulWidget {
  const PrivacyValue({
    super.key,
    required this.value,
    this.type = PrivacyValueType.general,
    this.label,
    this.maskChar,
    this.visibleLeading,
    this.visibleTrailing,
    this.dateStyle = DateMaskStyle.dayAndMonth,
    this.addressLevel = AddressMaskLevel.streetAndPremise,
    this.customMasker,
    this.style,
    this.labelStyle,
    this.showEyeToggle = true,
    this.showCopyButton = false,
    this.copyMasked = false,
    this.autoObscureDuration,
    this.showBadge = false,
    this.onRevealed,
    this.onHidden,
  });

  /// Factory constructor for mobile phone numbers.
  factory PrivacyValue.mobile({
    Key? key,
    required String value,
    String? label,
    int visibleLeading = 0,
    int visibleTrailing = 4,
    String maskChar = 'X',
    bool preserveCountryCode = true,
    TextStyle? style,
    TextStyle? labelStyle,
    bool showEyeToggle = true,
    bool showCopyButton = false,
    Duration? autoObscureDuration,
    bool showBadge = false,
  }) {
    return PrivacyValue(
      key: key,
      value: value,
      label: label,
      type: PrivacyValueType.mobile,
      visibleLeading: visibleLeading,
      visibleTrailing: visibleTrailing,
      maskChar: maskChar,
      style: style,
      labelStyle: labelStyle,
      showEyeToggle: showEyeToggle,
      showCopyButton: showCopyButton,
      autoObscureDuration: autoObscureDuration,
      showBadge: showBadge,
    );
  }

  /// Factory constructor for email addresses.
  factory PrivacyValue.email({
    Key? key,
    required String value,
    String? label,
    int visibleLeading = 1,
    int visibleTrailing = 1,
    String maskChar = '*',
    bool maskDomain = false,
    TextStyle? style,
    TextStyle? labelStyle,
    bool showEyeToggle = true,
    bool showCopyButton = false,
    Duration? autoObscureDuration,
    bool showBadge = false,
  }) {
    return PrivacyValue(
      key: key,
      value: value,
      label: label,
      type: PrivacyValueType.email,
      visibleLeading: visibleLeading,
      visibleTrailing: visibleTrailing,
      maskChar: maskChar,
      style: style,
      labelStyle: labelStyle,
      showEyeToggle: showEyeToggle,
      showCopyButton: showCopyButton,
      autoObscureDuration: autoObscureDuration,
      showBadge: showBadge,
      customMasker: (raw) => PrivacyMasker.maskEmail(
        raw,
        visibleLeading: visibleLeading,
        visibleTrailing: visibleTrailing,
        maskChar: maskChar,
        maskDomain: maskDomain,
      ),
    );
  }

  /// Factory constructor for birthdates.
  factory PrivacyValue.birthdate({
    Key? key,
    required dynamic value,
    String? label,
    DateMaskStyle dateStyle = DateMaskStyle.dayAndMonth,
    String maskChar = 'X',
    TextStyle? style,
    TextStyle? labelStyle,
    bool showEyeToggle = true,
    bool showCopyButton = false,
    Duration? autoObscureDuration,
    bool showBadge = false,
  }) {
    final stringValue = value is DateTime
        ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year.toString().padLeft(4, '0')}'
        : value.toString();

    return PrivacyValue(
      key: key,
      value: stringValue,
      label: label,
      type: PrivacyValueType.birthdate,
      dateStyle: dateStyle,
      maskChar: maskChar,
      style: style,
      labelStyle: labelStyle,
      showEyeToggle: showEyeToggle,
      showCopyButton: showCopyButton,
      autoObscureDuration: autoObscureDuration,
      showBadge: showBadge,
    );
  }

  /// Factory constructor for physical addresses.
  factory PrivacyValue.address({
    Key? key,
    required String value,
    String? label,
    AddressMaskLevel addressLevel = AddressMaskLevel.streetAndPremise,
    String maskChar = '*',
    int visiblePinDigits = 3,
    TextStyle? style,
    TextStyle? labelStyle,
    bool showEyeToggle = true,
    bool showCopyButton = false,
    Duration? autoObscureDuration,
    bool showBadge = false,
  }) {
    return PrivacyValue(
      key: key,
      value: value,
      label: label,
      type: PrivacyValueType.address,
      addressLevel: addressLevel,
      maskChar: maskChar,
      visibleLeading: visiblePinDigits,
      style: style,
      labelStyle: labelStyle,
      showEyeToggle: showEyeToggle,
      showCopyButton: showCopyButton,
      autoObscureDuration: autoObscureDuration,
      showBadge: showBadge,
      customMasker: (raw) => PrivacyMasker.maskAddress(
        raw,
        level: addressLevel,
        maskChar: maskChar,
        visiblePinDigits: visiblePinDigits,
      ),
    );
  }

  /// Factory constructor for general strings / tokens.
  factory PrivacyValue.general({
    Key? key,
    required String value,
    String? label,
    int visibleLeading = 0,
    int visibleTrailing = 4,
    String maskChar = 'X',
    TextStyle? style,
    TextStyle? labelStyle,
    bool showEyeToggle = true,
    bool showCopyButton = false,
    Duration? autoObscureDuration,
    bool showBadge = false,
  }) {
    return PrivacyValue(
      key: key,
      value: value,
      label: label,
      type: PrivacyValueType.general,
      visibleLeading: visibleLeading,
      visibleTrailing: visibleTrailing,
      maskChar: maskChar,
      style: style,
      labelStyle: labelStyle,
      showEyeToggle: showEyeToggle,
      showCopyButton: showCopyButton,
      autoObscureDuration: autoObscureDuration,
      showBadge: showBadge,
    );
  }

  /// The raw sensitive string value.
  final String value;

  /// The masking category.
  final PrivacyValueType type;

  /// Optional label above or beside the value (e.g. "Mobile Number").
  final String? label;

  /// Character to replace sensitive characters with (e.g. 'X', '*', '•').
  final String? maskChar;

  /// Number of characters to retain visible at start.
  final int? visibleLeading;

  /// Number of characters to retain visible at end.
  final int? visibleTrailing;

  /// Masking style for birthdates.
  final DateMaskStyle dateStyle;

  /// Masking level for addresses.
  final AddressMaskLevel addressLevel;

  /// Optional custom masking transformation.
  final String Function(String raw)? customMasker;

  /// Text style for the value.
  final TextStyle? style;

  /// Text style for the optional label.
  final TextStyle? labelStyle;

  /// Whether to display an inline eye icon button to toggle reveal/mask.
  final bool showEyeToggle;

  /// Whether to show a quick copy-to-clipboard button.
  final bool showCopyButton;

  /// If true, copies the masked representation; if false (default), copies raw value.
  final bool copyMasked;

  /// Optional duration to reveal the value before automatically re-obscuring it.
  final Duration? autoObscureDuration;

  /// Whether to show a discreet "MASKED" / "REVEALED" status badge.
  final bool showBadge;

  /// Callback when user reveals value.
  final VoidCallback? onRevealed;

  /// Callback when user re-hides value.
  final VoidCallback? onHidden;

  @override
  State<PrivacyValue> createState() => _PrivacyValueState();
}

class _PrivacyValueState extends State<PrivacyValue> {
  Timer? _autoObscureTimer;
  bool? _localOverrideUnmasked;

  @override
  void dispose() {
    _autoObscureTimer?.cancel();
    super.dispose();
  }

  void _toggleReveal(bool currentlyMasked) {
    if (currentlyMasked) {
      setState(() {
        _localOverrideUnmasked = true;
      });
      widget.onRevealed?.call();

      if (widget.autoObscureDuration != null) {
        _autoObscureTimer?.cancel();
        _autoObscureTimer = Timer(widget.autoObscureDuration!, () {
          if (mounted) {
            setState(() {
              _localOverrideUnmasked = false;
            });
            widget.onHidden?.call();
          }
        });
      }
    } else {
      _autoObscureTimer?.cancel();
      setState(() {
        _localOverrideUnmasked = false;
      });
      widget.onHidden?.call();
    }
  }

  String _computeMaskedValue() {
    if (widget.customMasker != null) {
      return widget.customMasker!(widget.value);
    }

    switch (widget.type) {
      case PrivacyValueType.mobile:
        return PrivacyMasker.maskMobile(
          widget.value,
          visibleLeading: widget.visibleLeading ?? 0,
          visibleTrailing: widget.visibleTrailing ?? 4,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.email:
        return PrivacyMasker.maskEmail(
          widget.value,
          visibleLeading: widget.visibleLeading ?? 1,
          visibleTrailing: widget.visibleTrailing ?? 1,
          maskChar: widget.maskChar ?? '*',
        );
      case PrivacyValueType.birthdate:
        return PrivacyMasker.maskBirthdate(
          widget.value,
          style: widget.dateStyle,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.address:
        return PrivacyMasker.maskAddress(
          widget.value,
          level: widget.addressLevel,
          maskChar: widget.maskChar ?? '*',
          visiblePinDigits: widget.visibleLeading ?? 3,
        );
      case PrivacyValueType.general:
        return PrivacyMasker.maskGeneral(
          widget.value,
          visibleStart: widget.visibleLeading ?? 0,
          visibleEnd: widget.visibleTrailing ?? 4,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.aadhaar:
        return PrivacyMasker.maskAadhaar(
          widget.value,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.pan:
        return PrivacyMasker.maskPan(
          widget.value,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.bankAccount:
        return PrivacyMasker.maskBankAccount(
          widget.value,
          visibleTrailing: widget.visibleTrailing ?? 4,
          maskChar: widget.maskChar ?? 'X',
        );
      case PrivacyValueType.card:
        return PrivacyMasker.maskCard(
          widget.value,
          visibleTrailing: widget.visibleTrailing ?? 4,
          maskChar: widget.maskChar ?? '•',
        );
    }
  }

  Future<void> _copyToClipboard(String textToCopy, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: textToCopy));
    HapticFeedback.lightImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.copyMasked ? 'Masked value copied' : 'Value copied securely',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyVaultController.isDataMasked,
      builder: (context, globalMasked, child) {
        // True if masked, false if revealed.
        // Local override takes precedence over global toggle.
        final bool isMasked = _localOverrideUnmasked != null
            ? !_localOverrideUnmasked!
            : globalMasked;

        final displayText = isMasked ? _computeMaskedValue() : widget.value;

        final textWidget = Text(
          displayText,
          style: widget.style ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
        );

        final content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: textWidget),
            if (widget.showBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isMasked
                      ? const Color(0x2210B981)
                      : const Color(0x22F59E0B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isMasked
                        ? const Color(0x5510B981)
                        : const Color(0x55F59E0B),
                  ),
                ),
                child: Text(
                  isMasked ? 'MASKED' : 'VISIBLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isMasked
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFBBF24),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            if (widget.showEyeToggle) ...[
              const SizedBox(width: 4),
              IconButton(
                iconSize: 18,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                splashRadius: 18,
                icon: Icon(
                  isMasked
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isMasked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
                tooltip: isMasked ? 'Reveal value' : 'Hide value',
                onPressed: () => _toggleReveal(isMasked),
              ),
            ],
            if (widget.showCopyButton) ...[
              const SizedBox(width: 4),
              IconButton(
                iconSize: 18,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                splashRadius: 18,
                icon: const Icon(Icons.copy_rounded),
                tooltip: widget.copyMasked ? 'Copy masked' : 'Copy securely',
                onPressed: () => _copyToClipboard(
                  widget.copyMasked ? displayText : widget.value,
                  context,
                ),
              ),
            ],
          ],
        );

        if (widget.label != null && widget.label!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label!,
                style: widget.labelStyle ??
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                          fontWeight: FontWeight.w500,
                        ),
              ),
              const SizedBox(height: 4),
              content,
            ],
          );
        }

        return content;
      },
    );
  }
}
