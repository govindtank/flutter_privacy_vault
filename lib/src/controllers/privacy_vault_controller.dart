import 'dart:async';
import 'package:flutter/widgets.dart';

/// Global controller managing app privacy states, inactivity locks, and sensitive data masking.
class PrivacyVaultController {
  PrivacyVaultController._();

  /// Whether the app is currently in background or multitasking task-switcher.
  static final ValueNotifier<bool> isAppInBackground =
      ValueNotifier<bool>(false);

  /// Whether the app vault is currently locked (requires PIN/Biometric unlock).
  static final ValueNotifier<bool> isLocked = ValueNotifier<bool>(false);

  /// Whether sensitive financial/personal data should be obscured.
  static final ValueNotifier<bool> isDataMasked = ValueNotifier<bool>(false);

  static Timer? _inactivityTimer;
  static Duration? _inactivityDuration;
  static bool _lockOnInactivity = false;
  static VoidCallback? _onLockedCallback;

  /// Initializes controller with configuration parameters.
  static void configure({
    Duration? inactivityTimeout,
    bool lockOnInactivity = false,
    bool initialDataMasked = false,
    VoidCallback? onLocked,
  }) {
    _inactivityDuration = inactivityTimeout;
    _lockOnInactivity = lockOnInactivity;
    _onLockedCallback = onLocked;
    isDataMasked.value = initialDataMasked;
    resetInactivityTimer();
  }

  /// Notifies user activity (touch, scroll, click, key event).
  static void registerUserActivity() {
    resetInactivityTimer();
  }

  /// Resets the inactivity countdown timer.
  static void resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_inactivityDuration == null || !_lockOnInactivity) return;

    _inactivityTimer = Timer(_inactivityDuration!, () {
      lock();
    });
  }

  /// Manually locks the vault.
  static void lock() {
    if (!isLocked.value) {
      isLocked.value = true;
      _onLockedCallback?.call();
    }
  }

  /// Manually unlocks the vault.
  static void unlock() {
    isLocked.value = false;
    resetInactivityTimer();
  }

  /// Toggles the sensitive data masking flag.
  static void toggleDataMasking() {
    isDataMasked.value = !isDataMasked.value;
  }

  /// Explicitly sets the sensitive data masking flag.
  static void setDataMasking(bool masked) {
    isDataMasked.value = masked;
  }

  /// Disposes timers and resets states (mainly for test cleanup).
  static void reset() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    isAppInBackground.value = false;
    isLocked.value = false;
    isDataMasked.value = false;
  }
}
