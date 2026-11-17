import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_privacy_vault/flutter_privacy_vault.dart';

void main() {
  group('PrivacyMasker - Mobile Number Masking (Indian Bank Standards)', () {
    test('masks standard 10-digit mobile number with default trailing 4 digits',
        () {
      final masked = PrivacyMasker.maskMobile('9876543210');
      expect(masked, equals('XXXXXX3210'));
    });

    test('preserves country code prefix (+91)', () {
      final masked = PrivacyMasker.maskMobile('+91 9876543210');
      expect(masked, equals('+91 XXXXXX3210'));
    });

    test('supports custom mask character and visible leading digits', () {
      final masked = PrivacyMasker.maskMobile(
        '9876543210',
        visibleLeading: 2,
        visibleTrailing: 2,
        maskChar: '*',
      );
      expect(masked, equals('98******10'));
    });

    test('preserves dash and space formatting', () {
      final masked = PrivacyMasker.maskMobile(
        '+91 98765-43210',
        maskChar: '*',
      );
      expect(masked, equals('+91 *****-*3210'));
    });

    test('string extension maskMobile works identically', () {
      expect(
          '+91 9123456789'.maskMobile(maskChar: '*'), equals('+91 ******6789'));
    });
  });

  group('PrivacyMasker - Email Masking', () {
    test('masks standard email username while keeping domain intact', () {
      final masked = PrivacyMasker.maskEmail('govindtank@gmail.com');
      // govindtank is 10 chars: 'g' + 8 mask chars + 'k'
      expect(masked, equals('g********k@gmail.com'));
    });

    test('custom visible leading and trailing characters', () {
      final masked = PrivacyMasker.maskEmail(
        'alexandra@domain.com',
        visibleLeading: 2,
        visibleTrailing: 2,
        maskChar: 'X',
      );
      expect(masked, equals('alXXXXXra@domain.com'));
    });

    test('supports domain masking for strict banking alerts', () {
      final masked = PrivacyMasker.maskEmail(
        'john.doe@icicibank.com',
        maskDomain: true,
        maskChar: '*',
      );
      expect(masked, equals('j******e@i*******k.com'));
    });

    test('handles very short usernames gracefully', () {
      expect(PrivacyMasker.maskEmail('a@bank.com'), equals('*@bank.com'));
      expect(PrivacyMasker.maskEmail('ab@bank.com'), equals('a*@bank.com'));
    });

    test('string extension maskEmail works identically', () {
      expect('user@hdfc.com'.maskEmail(maskChar: '*'), equals('u**r@hdfc.com'));
    });
  });

  group('PrivacyMasker - Birthdate Masking (KYC / Banking Style)', () {
    test('masks day and month, leaves year visible (Indian KYC standard)', () {
      final masked = PrivacyMasker.maskBirthdate('15/08/1995');
      expect(masked, equals('XX/XX/1995'));
    });

    test('masks year only, leaves day and month visible', () {
      final masked = PrivacyMasker.maskBirthdate(
        '24/11/1990',
        style: DateMaskStyle.yearOnly,
      );
      expect(masked, equals('24/11/XXXX'));
    });

    test('masks day and year, leaves month visible', () {
      final masked = PrivacyMasker.maskBirthdate(
        '10-06-2000',
        style: DateMaskStyle.dayAndYear,
        maskChar: '*',
      );
      expect(masked, equals('**-06-****'));
    });

    test('masks full date completely', () {
      final masked = PrivacyMasker.maskBirthdate(
        '01.01.1980',
        style: DateMaskStyle.full,
      );
      expect(masked, equals('XX.XX.XXXX'));
    });

    test('handles ISO format YYYY-MM-DD correctly', () {
      final masked = PrivacyMasker.maskBirthdate('1992-05-18');
      expect(masked, equals('1992-XX-XX'));
    });

    test('handles DateTime objects seamlessly', () {
      final dt = DateTime(1996, 7, 23);
      expect(
        PrivacyMasker.maskBirthdate(dt, style: DateMaskStyle.dayAndMonth),
        equals('XX/XX/1996'),
      );
    });

    test('string extension maskBirthdate works identically', () {
      expect('12/03/1998'.maskBirthdate(), equals('XX/XX/1998'));
    });
  });

  group('PrivacyMasker - Address Masking', () {
    const address =
        'Flat 402, Lotus Residency, MG Road, Mumbai, Maharashtra 400001';

    test('masks PIN code and premise number', () {
      final masked = PrivacyMasker.maskAddress(
        address,
        level: AddressMaskLevel.premiseOnly,
        visiblePinDigits: 3,
      );
      expect(masked.contains('Flat ***'), isTrue);
      expect(masked.contains('400***'), isTrue);
      expect(masked.contains('Mumbai'), isTrue);
    });

    test('masks street and premise', () {
      final masked = PrivacyMasker.maskAddress(
        address,
        level: AddressMaskLevel.streetAndPremise,
      );
      expect(masked.contains('Flat ***'), isTrue);
      expect(masked.contains('Lotus Residency'), isFalse);
      expect(masked.contains('Mumbai'), isTrue);
    });

    test('strict masking retains only city, state and partial PIN', () {
      final masked = PrivacyMasker.maskAddress(
        address,
        level: AddressMaskLevel.strict,
      );
      expect(masked.contains('Maharashtra 400***'), isTrue);
    });

    test('string extension maskAddress works identically', () {
      expect(address.maskAddress().contains('400***'), isTrue);
    });
  });

  group('PrivacyMasker - General & Banking Presets', () {
    test('general masking masks middle and retains start/end', () {
      final maskedWithDelimiters = PrivacyMasker.maskGeneral(
          'SECRET_TOKEN_9988',
          visibleStart: 2,
          visibleEnd: 4);
      expect(maskedWithDelimiters, equals('SEXXXX_XXXXX_9988'));

      final maskedNoDelimiters = PrivacyMasker.maskGeneral('SECRET_TOKEN_9988',
          visibleStart: 2, visibleEnd: 4, preserveDelimiters: false);
      expect(maskedNoDelimiters, equals('SEXXXXXXXXXXX9988'));
    });

    test('Indian Aadhaar UIDAI mask (XXXX XXXX 1234)', () {
      final masked = PrivacyMasker.maskAadhaar('5432 9876 1234');
      expect(masked, equals('XXXX XXXX 1234'));
      expect(
          '543298761234'.maskAadhaar(maskChar: '•'), equals('•••• •••• 1234'));
    });

    test('Indian PAN Card mask (XXXXX1234X)', () {
      final masked = PrivacyMasker.maskPan('ABCDE1234F');
      expect(masked, equals('XXXXX1234X'));
      expect('ABCDE1234F'.maskPan(showLastChar: true), equals('XXXXX1234F'));
    });

    test('Bank Account Number mask', () {
      final masked = PrivacyMasker.maskBankAccount('123456789012');
      expect(masked, equals('XXXXXXXX9012'));
    });

    test('Credit/Debit Card mask (•••• •••• •••• 1234)', () {
      final masked = PrivacyMasker.maskCard('4532 8901 2345 6789');
      expect(masked, equals('•••• •••• •••• 6789'));
    });
  });
}
