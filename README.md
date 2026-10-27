# flutter_privacy_vault

<p align="center">
  <a href="https://pub.dev/packages/flutter_privacy_vault"><img src="https://img.shields.io/pub/v/flutter_privacy_vault.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/flutter_privacy_vault/score"><img src="https://img.shields.io/pub/points/flutter_privacy_vault?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/flutter_privacy_vault/"><img src="https://img.shields.io/badge/Live%20Demo-Try%20In%20Browser-00ff88?style=flat-square&logo=flutter" alt="Live Demo"></a>
  <a href="https://pub.dev/packages/flutter_privacy_vault"><img src="https://img.shields.io/pub/likes/flutter_privacy_vault?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/flutter_privacy_vault/actions"><img src="https://github.com/govindtank/flutter_privacy_vault/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
</p>

A production security and privacy vault for Flutter applications. Built for Fintech, Banking, Crypto, and Healthcare apps requiring **app-switcher privacy shielding, inactivity auto-locking with biometric unlock, and selective sensitive data masking**.

---

## ⚡ Why `flutter_privacy_vault`?

Mobile operating systems automatically capture snapshots of your application interface when users switch apps or open the multitasking tray. For banking and confidential apps, this leaks account balances, card numbers, and confidential records.

`flutter_privacy_vault` provides a declarative, zero-native-headache solution:

* 🛡️ **App-Switcher Privacy Shield**: Detects when the app loses focus or enters the background, instantly overlaying a frosted Gaussian blur or branded lock screen.
* ⏱️ **Idle Inactivity Lock**: Tracks user touch, pointer, and keyboard interactions across the entire widget hierarchy. If the user is idle past your configured threshold (e.g. 60 seconds), it automatically locks the screen and triggers your biometric/PIN prompt.
* 👁️ **Sensitive Data Masking**: `PrivacyMask` widget allows wrapping balances (`$142,850.75` ➔ `••••••••` or Gaussian blur) with a global or localized toggle.
* 🌐 **Multi-Platform**: Pure Flutter implementation with zero platform channel crashes across iOS, Android, Web, macOS, Windows, and Linux.

---

## 🚀 Features

| Feature | Description |
|---|---|
| **🛡️ Background Privacy Shield** | Automatic Gaussian blur or custom branded overlay when the app moves to background or the multitasking switcher. |
| **⏱️ Inactivity Auto-Lock** | Listens to all user interaction events with zero UI performance penalty; locks vault upon timeout. |
| **👁️ PrivacyMask Widget** | Selective masking for numbers and text with `bullets` (`••••••••`), `blur`, or `redacted` styles. |
| **📱 Biometric / PIN Hooks** | Simple callbacks (`onLocked`, `onUnlocked`) to wire into `local_auth` or custom PIN pads. |
| **⚡ Reactive Controller** | Global `PrivacyVaultController` to query `isLocked`, `isDataMasked`, or manually trigger locks. |

---

## 📦 Installation

Add `flutter_privacy_vault` to your `pubspec.yaml`:

```bash
flutter pub add flutter_privacy_vault
```

---

## 💡 Quick Start

### 1. Wrap your App Root in `PrivacyVault`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return PrivacyVault(
          config: PrivacyVaultConfig(
            enableBackgroundShield: true,
            inactivityTimeout: const Duration(minutes: 2),
            lockOnInactivity: true,
            onLocked: () => print('Vault locked!'),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const BankingHomeScreen(),
    );
  }
}
```

---

### 2. Mask Sensitive Balances & Fields

```dart
// Bullets masking ($14,250.00 -> ••••••••)
PrivacyMask(
  style: MaskingStyle.bullets,
  child: Text(
    '\$14,250.00',
    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  ),
)

// Gaussian blur masking
PrivacyMask(
  style: MaskingStyle.blur,
  blurSigma: 6.0,
  child: Text('Card: 4820 9182 4410 9921'),
)
```

---

### 3. Programmatic Controls

```dart
// Toggle masking for all PrivacyMask widgets in your app
PrivacyVaultController.toggleDataMasking();

// Manually lock vault (e.g. user taps "Lock Now")
PrivacyVaultController.lock();

// Unlock vault (e.g. after successful fingerprint check)
PrivacyVaultController.unlock();
```

---

## 🔗 Related Packages by Author

* **[ai_stream_bubble](https://pub.dev/packages/ai_stream_bubble)** — High-performance streaming AI message bubble with DeepSeek/Claude reasoning accordions.
* **[flutter_sonner](https://pub.dev/packages/flutter_sonner)** — Opinionated stacked action toast & notification HUD with spring physics.
* **[ai_voice_orb](https://pub.dev/packages/ai_voice_orb)** — Fluid neural voice orb for Conversational AI & voice agents.
* **[spatial_card](https://pub.dev/packages/spatial_card)** — 3D tactile interactive cards & multi-plane parallax surfaces.

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
