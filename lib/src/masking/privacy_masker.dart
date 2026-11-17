import 'package:flutter/foundation.dart';

/// Style configuration for birthdate masking.
enum DateMaskStyle {
  /// Masks Day and Month, leaving Year visible (e.g. `XX/XX/1995`).
  /// Standard in Indian banking and KYC age verification.
  dayAndMonth,

  /// Masks Year only, leaving Day and Month visible (e.g. `15/08/XXXX`).
  yearOnly,

  /// Masks Day and Year, leaving Month visible (e.g. `XX/08/XXXX`).
  dayAndYear,

  /// Masks all date components completely (e.g. `XX/XX/XXXX`).
  full,
}

/// Level of masking applied to postal/street address.
enum AddressMaskLevel {
  /// Masks only flat/house/plot premise number (e.g. `Flat ***, Sky Tower, MG Road, Mumbai 400001`).
  premiseOnly,

  /// Masks flat/plot and street name, revealing locality, city, state and partial PIN.
  /// (e.g. `***, **********, Andheri East, Mumbai, Maharashtra 400***`).
  streetAndPremise,

  /// Strict privacy: masks everything except city, state and partial PIN.
  strict,
}

/// Bank-grade masking engine for sensitive PII (Personally Identifiable Information).
/// Inspired by Indian banking standards (HDFC, SBI, ICICI, Axis, Zerodha).
@immutable
class PrivacyMasker {
  const PrivacyMasker._();

  /// Masks a mobile phone number according to banking standards.
  ///
  /// Examples:
  /// - `+91 9876543210` -> `+91 ******3210`
  /// - `9876543210` with `visibleLeading: 2` -> `98****3210`
  /// - `9876543210` with `maskChar: 'X'` -> `XXXXXX3210`
  static String maskMobile(
    String mobile, {
    int visibleLeading = 0,
    int visibleTrailing = 4,
    String maskChar = 'X',
    bool preserveCountryCode = true,
    bool preserveFormatting = true,
    int? fixedMaskLength,
  }) {
    final trimmed = mobile.trim();
    if (trimmed.isEmpty) return trimmed;

    // Detect country code prefix like "+91 " or "+91-" or "+1 "
    String prefix = '';
    String core = trimmed;

    if (preserveCountryCode && trimmed.startsWith('+')) {
      final codeMatch = RegExp(r'^\+\d{1,4}[\s\-]?').firstMatch(trimmed);
      if (codeMatch != null) {
        prefix = codeMatch.group(0)!;
        core = trimmed.substring(prefix.length);
      }
    }

    if (!preserveFormatting) {
      core = core.replaceAll(RegExp(r'[\s\-]'), '');
    }

    final digitsOnly = core.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length <= (visibleLeading + visibleTrailing)) {
      return prefix + (maskChar * core.length);
    }

    if (preserveFormatting) {
      // Walk through core characters, keeping non-digit formatters
      int digitIndex = 0;
      final totalDigits = digitsOnly.length;
      final unmaskedLeadingEnd = visibleLeading;
      final unmaskedTrailingStart = totalDigits - visibleTrailing;

      final buffer = StringBuffer();
      for (int i = 0; i < core.length; i++) {
        final char = core[i];
        if (RegExp(r'\d').hasMatch(char)) {
          if (digitIndex < unmaskedLeadingEnd ||
              digitIndex >= unmaskedTrailingStart) {
            buffer.write(char);
          } else {
            buffer.write(maskChar);
          }
          digitIndex++;
        } else {
          buffer.write(char);
        }
      }
      return prefix + buffer.toString();
    } else {
      final leading = digitsOnly.substring(0, visibleLeading);
      final trailing =
          digitsOnly.substring(digitsOnly.length - visibleTrailing);
      final maskCount = fixedMaskLength ??
          (digitsOnly.length - visibleLeading - visibleTrailing);
      return prefix + leading + (maskChar * maskCount) + trailing;
    }
  }

  /// Masks an email address according to banking & KYC standards.
  ///
  /// Examples:
  /// - `user@example.com` -> `u***@example.com`
  /// - `govindtank@gmail.com` with `visibleLeading: 2, visibleTrailing: 1` -> `go******k@gmail.com`
  /// - With `maskDomain: true` -> `go******k@g*****.com`
  static String maskEmail(
    String email, {
    int visibleLeading = 1,
    int visibleTrailing = 1,
    String maskChar = '*',
    bool maskDomain = false,
    int? fixedMaskLength,
  }) {
    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      return maskGeneral(trimmed,
          visibleStart: visibleLeading,
          visibleEnd: visibleTrailing,
          maskChar: maskChar);
    }

    final parts = trimmed.split('@');
    final username = parts[0];
    final domain = parts.length > 1 ? parts.sublist(1).join('@') : '';

    String maskedUsername;
    if (username.length <= 1) {
      maskedUsername = maskChar;
    } else if (username.length == 2) {
      maskedUsername = '${username[0]}$maskChar';
    } else if (username.length <= (visibleLeading + visibleTrailing)) {
      maskedUsername = '${username[0]}${maskChar * (username.length - 1)}';
    } else {
      final lead = username.substring(0, visibleLeading);
      final trail = visibleTrailing > 0
          ? username.substring(username.length - visibleTrailing)
          : '';
      final maskCount = fixedMaskLength ??
          (username.length - visibleLeading - visibleTrailing);
      maskedUsername =
          lead + (maskChar * (maskCount > 0 ? maskCount : 1)) + trail;
    }

    String finalDomain = domain;
    if (maskDomain && domain.isNotEmpty) {
      final dotIndex = domain.lastIndexOf('.');
      if (dotIndex > 0) {
        final domainName = domain.substring(0, dotIndex);
        final tld = domain.substring(dotIndex);
        if (domainName.length <= 2) {
          finalDomain = '${domainName[0]}$maskChar$tld';
        } else {
          finalDomain =
              '${domainName[0]}${maskChar * (domainName.length - 2)}${domainName[domainName.length - 1]}$tld';
        }
      }
    }

    return '$maskedUsername@$finalDomain';
  }

  /// Masks a birthdate according to banking and KYC verification conventions.
  ///
  /// Supports:
  /// - `DateTime` objects
  /// - String dates in `DD/MM/YYYY`, `DD-MM-YYYY`, `YYYY-MM-DD`, `DD.MM.YYYY`, `DD Mon YYYY`
  ///
  /// Examples:
  /// - `15/08/1995` with [DateMaskStyle.dayAndMonth] -> `XX/XX/1995`
  /// - `15/08/1995` with [DateMaskStyle.yearOnly] -> `15/08/XXXX`
  /// - `1995-08-15` (ISO) with [DateMaskStyle.dayAndMonth] -> `1995-XX-XX`
  static String maskBirthdate(
    dynamic date, {
    DateMaskStyle style = DateMaskStyle.dayAndMonth,
    String maskChar = 'X',
  }) {
    if (date == null) return '';

    if (date is DateTime) {
      final d = date.day.toString().padLeft(2, '0');
      final m = date.month.toString().padLeft(2, '0');
      final y = date.year.toString().padLeft(4, '0');

      switch (style) {
        case DateMaskStyle.dayAndMonth:
          return '${maskChar * 2}/${maskChar * 2}/$y';
        case DateMaskStyle.yearOnly:
          return '$d/$m/${maskChar * 4}';
        case DateMaskStyle.dayAndYear:
          return '${maskChar * 2}/$m/${maskChar * 4}';
        case DateMaskStyle.full:
          return '${maskChar * 2}/${maskChar * 2}/${maskChar * 4}';
      }
    }

    final dateStr = date.toString().trim();
    if (dateStr.isEmpty) return dateStr;

    // Detect separator: '/', '-', '.', ' '
    final separatorMatch = RegExp(r'[/.\-\s]').firstMatch(dateStr);
    final sep = separatorMatch != null ? separatorMatch.group(0)! : '/';
    final parts = dateStr.split(sep);

    if (parts.length != 3) {
      return maskGeneral(dateStr,
          visibleStart: 0, visibleEnd: 4, maskChar: maskChar);
    }

    // Check if ISO format YYYY-MM-DD (part 0 has 4 digits)
    final isYearFirst =
        parts[0].length == 4 && RegExp(r'^\d{4}$').hasMatch(parts[0]);

    String p0 = parts[0];
    String p1 = parts[1];
    String p2 = parts[2];

    if (isYearFirst) {
      // YYYY [sep] MM [sep] DD
      switch (style) {
        case DateMaskStyle.dayAndMonth:
          p1 = maskChar * p1.length;
          p2 = maskChar * p2.length;
          break;
        case DateMaskStyle.yearOnly:
          p0 = maskChar * p0.length;
          break;
        case DateMaskStyle.dayAndYear:
          p0 = maskChar * p0.length;
          p2 = maskChar * p2.length;
          break;
        case DateMaskStyle.full:
          p0 = maskChar * p0.length;
          p1 = maskChar * p1.length;
          p2 = maskChar * p2.length;
          break;
      }
    } else {
      // DD [sep] MM [sep] YYYY
      switch (style) {
        case DateMaskStyle.dayAndMonth:
          p0 = maskChar * p0.length;
          p1 = maskChar * p1.length;
          break;
        case DateMaskStyle.yearOnly:
          p2 = maskChar * p2.length;
          break;
        case DateMaskStyle.dayAndYear:
          p0 = maskChar * p0.length;
          p2 = maskChar * p2.length;
          break;
        case DateMaskStyle.full:
          p0 = maskChar * p0.length;
          p1 = maskChar * p1.length;
          p2 = maskChar * p2.length;
          break;
      }
    }

    return '$p0$sep$p1$sep$p2';
  }

  /// Masks a physical address for privacy against shoulder surfing while retaining
  /// verifiable city, state, and partial postal code.
  ///
  /// Examples:
  /// - `Flat 402, Lotus Residency, MG Road, Mumbai 400001` with [AddressMaskLevel.streetAndPremise]
  ///   -> `Flat ***, ***************, MG Road, Mumbai 400***`
  static String maskAddress(
    String address, {
    AddressMaskLevel level = AddressMaskLevel.streetAndPremise,
    String maskChar = '*',
    int visiblePinDigits = 3,
  }) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return trimmed;

    // First, mask postal/PIN codes (5 or 6 consecutive digits)
    String masked = trimmed.replaceAllMapped(RegExp(r'\b(\d{5,6})\b'), (match) {
      final pin = match.group(1)!;
      if (visiblePinDigits >= pin.length) return pin;
      final visible = pin.substring(0, visiblePinDigits);
      final maskedDigits = maskChar * (pin.length - visiblePinDigits);
      return '$visible$maskedDigits';
    });

    final segments = masked.split(RegExp(r',\s*'));
    if (segments.length <= 1) {
      // Fallback for non-comma-separated addresses: mask first 60%
      final cutOff = (masked.length * 0.5).round();
      return (maskChar * cutOff) + masked.substring(cutOff);
    }

    switch (level) {
      case AddressMaskLevel.premiseOnly:
        // Mask premise/house number in first segment, e.g. "Flat 402" -> "Flat ***"
        segments[0] = segments[0].replaceAllMapped(
          RegExp(r'\d+'),
          (m) => maskChar * m.group(0)!.length,
        );
        break;

      case AddressMaskLevel.streetAndPremise:
        // Mask first segment numbers/words
        segments[0] = segments[0].replaceAllMapped(
          RegExp(r'\d+'),
          (m) => maskChar * m.group(0)!.length,
        );
        if (segments.length > 2) {
          // Mask the building/society or street name in segment 1
          final s1 = segments[1];
          segments[1] = s1.replaceAllMapped(
            RegExp(r'[a-zA-Z0-9]'),
            (m) => maskChar,
          );
        }
        break;

      case AddressMaskLevel.strict:
        // Keep only the last 2 segments (typically City, State PIN)
        final keepFrom = (segments.length - 2).clamp(1, segments.length);
        for (int i = 0; i < keepFrom; i++) {
          segments[i] = segments[i].replaceAllMapped(
            RegExp(r'[a-zA-Z0-9]'),
            (m) => maskChar,
          );
        }
        break;
    }

    return segments.join(', ');
  }

  /// General-purpose masking for any sensitive token, ID, or custom string.
  ///
  /// Examples:
  /// - `1234567890` with `visibleStart: 2, visibleEnd: 2` -> `12XXXXXX90`
  /// - `SECRET_KEY_12345` with `fixedMaskLength: 8` -> `XXXXXXXX`
  static String maskGeneral(
    String input, {
    int visibleStart = 0,
    int visibleEnd = 4,
    String maskChar = 'X',
    int? fixedMaskLength,
    bool preserveDelimiters = true,
  }) {
    if (input.isEmpty) return input;

    if (input.length <= (visibleStart + visibleEnd)) {
      return maskChar * input.length;
    }

    if (preserveDelimiters) {
      final buffer = StringBuffer();
      final total = input.length;
      final startBoundary = visibleStart;
      final endBoundary = total - visibleEnd;

      for (int i = 0; i < total; i++) {
        final char = input[i];
        if (i < startBoundary || i >= endBoundary) {
          buffer.write(char);
        } else if (RegExp(r'[\s\-_\.,/@:]').hasMatch(char)) {
          buffer.write(char);
        } else {
          buffer.write(maskChar);
        }
      }
      return buffer.toString();
    } else {
      final start = input.substring(0, visibleStart);
      final end = input.substring(input.length - visibleEnd);
      final count =
          fixedMaskLength ?? (input.length - visibleStart - visibleEnd);
      return start + (maskChar * count) + end;
    }
  }

  /// Masks a 12-digit Indian Aadhaar number according to official UIDAI specifications:
  /// First 8 digits masked, last 4 digits visible (`XXXX XXXX 1234`).
  static String maskAadhaar(String aadhaar, {String maskChar = 'X'}) {
    final cleaned = aadhaar.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length != 12) {
      return maskGeneral(aadhaar,
          visibleStart: 0, visibleEnd: 4, maskChar: maskChar);
    }
    final last4 = cleaned.substring(8);
    final block = maskChar * 4;
    return '$block $block $last4';
  }

  /// Masks an Indian Permanent Account Number (PAN Card):
  /// e.g. `ABCDE1234F` -> `XXXXX1234X` or `***XX1234*`.
  static String maskPan(
    String pan, {
    String maskChar = 'X',
    bool showLastChar = false,
  }) {
    final cleaned = pan.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (cleaned.length != 10) {
      return maskGeneral(pan,
          visibleStart: 0, visibleEnd: 4, maskChar: maskChar);
    }
    final middleDigits = cleaned.substring(5, 9);
    final lastChar = showLastChar ? cleaned[9] : maskChar;
    return '${maskChar * 5}$middleDigits$lastChar';
  }

  /// Masks a bank account number (usually 9 to 18 digits):
  /// e.g. `123456789012` -> `XXXXXXXX9012`.
  static String maskBankAccount(
    String accountNumber, {
    int visibleTrailing = 4,
    String maskChar = 'X',
  }) {
    return maskGeneral(
      accountNumber,
      visibleStart: 0,
      visibleEnd: visibleTrailing,
      maskChar: maskChar,
      preserveDelimiters: false,
    );
  }

  /// Masks a debit/credit card number (16 digits formatted in 4-digit groups):
  /// e.g. `4532 8901 2345 6789` -> `•••• •••• •••• 6789`.
  static String maskCard(
    String cardNumber, {
    int visibleTrailing = 4,
    String maskChar = '•',
  }) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 12) {
      return maskGeneral(cardNumber,
          visibleStart: 0, visibleEnd: visibleTrailing, maskChar: maskChar);
    }
    final lastDigits = cleaned.substring(cleaned.length - visibleTrailing);
    return '${maskChar * 4} ${maskChar * 4} ${maskChar * 4} $lastDigits';
  }
}

/// Convenience extensions on [String] for seamless bank masking.
extension PrivacyMaskStringExtensions on String {
  /// Masks as mobile number.
  String maskMobile({
    int visibleLeading = 0,
    int visibleTrailing = 4,
    String maskChar = 'X',
    bool preserveCountryCode = true,
  }) =>
      PrivacyMasker.maskMobile(
        this,
        visibleLeading: visibleLeading,
        visibleTrailing: visibleTrailing,
        maskChar: maskChar,
        preserveCountryCode: preserveCountryCode,
      );

  /// Masks as email address.
  String maskEmail({
    int visibleLeading = 1,
    int visibleTrailing = 1,
    String maskChar = '*',
    bool maskDomain = false,
  }) =>
      PrivacyMasker.maskEmail(
        this,
        visibleLeading: visibleLeading,
        visibleTrailing: visibleTrailing,
        maskChar: maskChar,
        maskDomain: maskDomain,
      );

  /// Masks as birthdate.
  String maskBirthdate({
    DateMaskStyle style = DateMaskStyle.dayAndMonth,
    String maskChar = 'X',
  }) =>
      PrivacyMasker.maskBirthdate(this, style: style, maskChar: maskChar);

  /// Masks as address.
  String maskAddress({
    AddressMaskLevel level = AddressMaskLevel.streetAndPremise,
    String maskChar = '*',
    int visiblePinDigits = 3,
  }) =>
      PrivacyMasker.maskAddress(
        this,
        level: level,
        maskChar: maskChar,
        visiblePinDigits: visiblePinDigits,
      );

  /// Masks with general rules.
  String maskGeneral({
    int visibleStart = 0,
    int visibleEnd = 4,
    String maskChar = 'X',
    int? fixedMaskLength,
  }) =>
      PrivacyMasker.maskGeneral(
        this,
        visibleStart: visibleStart,
        visibleEnd: visibleEnd,
        maskChar: maskChar,
        fixedMaskLength: fixedMaskLength,
      );

  /// Masks as Indian Aadhaar number.
  String maskAadhaar({String maskChar = 'X'}) =>
      PrivacyMasker.maskAadhaar(this, maskChar: maskChar);

  /// Masks as Indian PAN card.
  String maskPan({String maskChar = 'X', bool showLastChar = false}) =>
      PrivacyMasker.maskPan(this,
          maskChar: maskChar, showLastChar: showLastChar);

  /// Masks as bank account number.
  String maskBankAccount({int visibleTrailing = 4, String maskChar = 'X'}) =>
      PrivacyMasker.maskBankAccount(this,
          visibleTrailing: visibleTrailing, maskChar: maskChar);

  /// Masks as payment card.
  String maskCard({int visibleTrailing = 4, String maskChar = '•'}) =>
      PrivacyMasker.maskCard(this,
          visibleTrailing: visibleTrailing, maskChar: maskChar);
}
