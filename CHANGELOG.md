## 1.3.0

* **Bank-Grade PII Masking Engine (`PrivacyMasker`)**: Comprehensive masking algorithms inspired by Indian banking standards (HDFC, SBI, ICICI, Axis, Zerodha, UIDAI):
  * **Birthdate Masking**: Mask Day and Month while preserving Year (`XX/XX/1995`) for KYC age verification, or mask Year (`15/08/XXXX`), or full date masking.
  * **Mobile Number Masking**: Standard Indian banking format (`+91 ******1234` or `XXXXXX1234`) with customizable visible leading/trailing digits, mask character (`X`, `*`, `•`), and country code preservation.
  * **Email Masking**: Shields username while keeping domain visible (`g********k@hdfcbank.com`), with customizable leading/trailing character counts and optional domain shielding (`@h******k.com`).
  * **Address Masking**: Hides street and premise/flat numbers (`Flat ***, ***************`) while preserving locality, city, state, and partial PIN code (`Bengaluru, Karnataka - 560***`).
  * **General Masking & Banking Presets**: Customizable generic string masker, plus built-in official formats for UIDAI Aadhaar (`XXXX XXXX 1234`), Income Tax PAN (`XXXXX1234X`), Bank Account Number (`XXXXXXXX4892`), and Payment Cards (`•••• •••• •••• 6789`).
  * **Convenience String Extensions**: Direct inline extensions (`'9876543210'.maskMobile()`, `'user@bank.com'.maskEmail()`, `'15/08/1995'.maskBirthdate()`, `'Flat 402, ...'.maskAddress()`).
* **New `PrivacyValue` Widget**: Production-ready banking widget rendering sensitive PII with:
  * 1-tap eye reveal/obscure toggle.
  * Timed auto-reobscure duration to prevent shoulder-surfing.
  * One-click secure clipboard copy (with optional masked copy).
  * Discreet status badges (`MASKED` / `VISIBLE`).
  * Reacts to global `PrivacyVaultController.isDataMasked` automatically.
* **Interactive Live Demo Showcase**: Overhauled web showcase with live interactive customization sliders, dropdowns, and toggles for all 5 masking categories.
* **Introductory Showcase Graphics**: Added dedicated working vector demonstration diagrams (`bank_pii_masking_demo.svg` & updated `privacy_vault_showcase.svg`) visually illustrating working UI cards with zero unnecessary prose.

## 1.2.1

* **Discovery & Metadata**: Added official funding channels and refined search discovery topics.

## 1.2.0

- **Showcase Visuals**: Added crisp dark-mode vector SVG showcase banner in README documentation.
- **Cleaner Distribution**: Excluded example platform directories via `.pubignore` for a smaller package archive.

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
