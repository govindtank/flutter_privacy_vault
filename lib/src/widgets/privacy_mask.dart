import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/privacy_vault_controller.dart';
import '../models/privacy_config.dart';

/// Wraps sensitive data (account balances, API keys, personal IDs) with automated
/// masking based on [PrivacyVaultController.isDataMasked], with optional inline eye toggle
/// and timed auto-reobscure duration.
class PrivacyMask extends StatefulWidget {
  const PrivacyMask({
    super.key,
    required this.child,
    this.style = MaskingStyle.bullets,
    this.replacementText = '••••••••',
    this.blurSigma = 8.0,
    this.redactedColor,
    this.allowTapToggle = false,
    this.showEyeButton = false,
    this.autoObscureDuration,
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

  /// Whether to show an inline eye icon button to reveal/hide.
  final bool showEyeButton;

  /// Optional duration to reveal the value before automatically re-obscuring it.
  final Duration? autoObscureDuration;

  @override
  State<PrivacyMask> createState() => _PrivacyMaskState();
}

class _PrivacyMaskState extends State<PrivacyMask> {
  Timer? _autoObscureTimer;
  bool? _localOverrideUnmasked;

  @override
  void dispose() {
    _autoObscureTimer?.cancel();
    super.dispose();
  }

  void _triggerTimedReveal() {
    setState(() => _localOverrideUnmasked = true);
    _autoObscureTimer?.cancel();

    if (widget.autoObscureDuration != null) {
      _autoObscureTimer = Timer(widget.autoObscureDuration!, () {
        if (mounted) {
          setState(() => _localOverrideUnmasked = false);
        }
      });
    }
  }

  void _toggleReveal(bool globalMasked) {
    if (_localOverrideUnmasked == true) {
      _autoObscureTimer?.cancel();
      setState(() => _localOverrideUnmasked = false);
    } else {
      _triggerTimedReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PrivacyVaultController.isDataMasked,
      builder: (context, globalMasked, _) {
        final isMasked = _localOverrideUnmasked != null
            ? !_localOverrideUnmasked!
            : globalMasked;

        Widget content;

        if (!isMasked) {
          content = widget.child;
        } else {
          switch (widget.style) {
            case MaskingStyle.bullets:
              content = Text(
                widget.replacementText,
                style: const TextStyle(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              );
            case MaskingStyle.blur:
              content = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: widget.child,
              );
            case MaskingStyle.redacted:
              content = Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: widget.redactedColor ??
                      Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Opacity(
                  opacity: 0.0,
                  child: widget.child,
                ),
              );
          }
        }

        if (widget.allowTapToggle) {
          content = InkWell(
            onTap: () => _toggleReveal(globalMasked),
            borderRadius: BorderRadius.circular(4.0),
            child: content,
          );
        }

        if (widget.showEyeButton) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              content,
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _toggleReveal(globalMasked),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    isMasked
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }
}
