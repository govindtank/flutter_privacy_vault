import 'package:flutter/material.dart';

/// The visual presentation style of the privacy shield overlay.
enum PrivacyShieldMode {
  /// Frosted glass Gaussian blur obscuring underlying contents.
  blur,

  /// Solid opaque or translucent color fill.
  color,

  /// Custom widget builder.
  custom,
}

/// The masking presentation for sensitive data elements (e.g. account balance).
enum MaskingStyle {
  /// Replaces characters with discreet privacy bullets (`••••••`).
  bullets,

  /// Applies a localized Gaussian blur filter over the child widget.
  blur,

  /// Black/gray redacted rectangle bar.
  redacted,
}

/// Configuration options for [flutter_privacy_vault].
@immutable
class PrivacyVaultConfig {
  const PrivacyVaultConfig({
    this.enableBackgroundShield = true,
    this.shieldMode = PrivacyShieldMode.blur,
    this.blurSigma = 18.0,
    this.shieldColor = const Color(0xEB0A0A0C),
    this.inactivityTimeout,
    this.lockOnInactivity = false,
    this.backgroundGracePeriod,
    this.maskSensitiveDataByDefault = false,
    this.pinLength = 4,
    this.correctPin,
    this.shufflePinKeypad = false,
    this.customShieldBuilder,
    this.customLockScreenBuilder,
    this.onLocked,
    this.onUnlocked,
  });

  /// Automatically obscure screen when app is backgrounded or in multitasking switcher.
  final bool enableBackgroundShield;

  /// The visual presentation style of the shield.
  final PrivacyShieldMode shieldMode;

  /// Gaussian blur intensity for [PrivacyShieldMode.blur].
  final double blurSigma;

  /// Background color fill for the shield overlay.
  final Color shieldColor;

  /// Duration of user inactivity before triggering an automatic lock.
  final Duration? inactivityTimeout;

  /// Whether to require unlocking when [inactivityTimeout] is reached.
  final bool lockOnInactivity;

  /// Grace period before backgrounding locks the app (useful for 2FA authenticator apps).
  final Duration? backgroundGracePeriod;

  /// Initial state for masking sensitive data (e.g., account balances).
  final bool maskSensitiveDataByDefault;

  /// Length of PIN digits when using built-in PIN pad (4 or 6 digits).
  final int pinLength;

  /// Correct PIN required to unlock when using built-in PIN verification.
  final String? correctPin;

  /// Randomly shuffles the keypad numbers on each launch to prevent shoulder-surfing.
  final bool shufflePinKeypad;

  /// Custom widget builder for the app-switcher background shield.
  final WidgetBuilder? customShieldBuilder;

  /// Custom unlock/PIN/biometric screen builder when app is locked.
  final Widget Function(BuildContext context, VoidCallback unlock)?
      customLockScreenBuilder;

  /// Callback dispatched when the vault locks.
  final VoidCallback? onLocked;

  /// Callback dispatched when the vault unlocks.
  final VoidCallback? onUnlocked;
}
