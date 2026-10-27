import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/privacy_vault_controller.dart';
import '../models/privacy_config.dart';

/// Wraps sensitive data (account balances, API keys, personal IDs) with automated
/// masking based on [PrivacyVaultController.isDataMasked].
class PrivacyMask extends StatelessWidget {
  const PrivacyMask({
    super.key,
    required this.child,
    this.style = MaskingStyle.bullets,
    this.replacementText = '••••••••',
    this.blurSigma = 8.0,
    this.redactedColor,
    this.allowTapToggle = false,
  });

  /// The original sensitive widget (e.g. `Text('\$24,500.00')`).
  final Widget child;

  /// Masking presentation style.
  final MaskingStyle style;

  /// Replacement text when [style] is [MaskingStyle.bullets].
  final String replacementText;

  /// Blur intensity when [style] is [MaskingStyle.blur].
  final double blurSigma;

  /// Redaction color fill when [style] is [MaskingStyle.redacted].
  final Color? redactedColor;

  /// If true, tapping this widget toggles masking for this element.
  final bool allowTapToggle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyVaultController.isDataMasked,
      builder: (context, isMasked, _) {
        Widget content;

        if (!isMasked) {
          content = child;
        } else {
          switch (style) {
            case MaskingStyle.bullets:
              content = Text(
                replacementText,
                style: const TextStyle(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            case MaskingStyle.blur:
              content = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: child,
              );
            case MaskingStyle.redacted:
              content = Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: redactedColor ??
                      Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Opacity(
                  opacity: 0.0,
                  child: child,
                ),
              );
          }
        }

        if (allowTapToggle) {
          return InkWell(
            onTap: () => PrivacyVaultController.toggleDataMasking(),
            borderRadius: BorderRadius.circular(4.0),
            child: content,
          );
        }

        return content;
      },
    );
  }
}
