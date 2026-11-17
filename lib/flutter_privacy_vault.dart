/// Security and privacy vault for Flutter.
///
/// Features app-switcher privacy shielding, user inactivity auto-locking,
/// selective masking of sensitive financial data (birthdate, mobile, email, address, general PII),
/// and built-in anti-shoulder-surfing PIN pad.
library;

export 'src/controllers/privacy_vault_controller.dart';
export 'src/masking/privacy_masker.dart';
export 'src/models/privacy_config.dart';
export 'src/widgets/privacy_mask.dart';
export 'src/widgets/privacy_value.dart';
export 'src/widgets/privacy_vault.dart';
export 'src/widgets/vault_pin_pad.dart';
