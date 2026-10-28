## 1.1.0

- **Built-in `VaultPinPad` Widget**: High-security numeric PIN keypad with optional randomized keypad shuffling (`shuffleKeypad: true`) to prevent shoulder-surfing.
- **Timed Auto-Reobscure for `PrivacyMask`**: Added `autoObscureDuration` to automatically obscure revealed values after a configured duration (e.g. 5 seconds).
- **Inline Eye Toggle Button**: Added `showEyeButton: true` for convenient 1-tap revealing/obscuring of individual fields.
- **Background Grace Period**: Added `backgroundGracePeriod` to avoid premature locking during rapid app transitions (such as copying 2FA authenticator codes).

## 1.0.0

- Initial release of `flutter_privacy_vault`.
- **App-Switcher Privacy Shield**: Automatic blur/frosted overlay or branded splash when moving to background / multitasking tray.
- **Inactivity Auto-Lock**: User idle detection across touch, pointer, and key events with configurable timeout and biometric unlock triggers.
- **Sensitive Data Masking**: `PrivacyMask` widget with dot obscuring (`••••••`) and blur filter modes for account balances and credentials.
- **Privacy Controller**: Global reactive state manager for privacy flags, obscuring modes, and lock triggers.
- **Multi-Platform Ready**: 100% pure Flutter implementation compatible with iOS, Android, Web, macOS, Windows, and Linux.
