class Validators {
  Validators._();

  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int maxAddressLength = 255;
  static const int maxCityLength = 100;
  static const int maxCommentLength = 500;
  static const int maxPostalCodeLength = 10;
  static const int maxPhoneLength = 16;

  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  static final RegExp _strictTextRegex = RegExp(r"^[A-Za-z][A-Za-z' -]*$");

  static final RegExp _referenceRegex = RegExp(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$");

  static final RegExp _phoneAllowedCharsRegex = RegExp(r"^\+?[0-9 ]+$");

  static final RegExp _postalAllowedCharsRegex = RegExp(r"^[A-Za-z0-9 -]+$");

  static final List<CountryRule> _countries = [
    CountryRule(
      code: 'FR',
      name: 'France',
      dialCode: '+33',
      postalRegex: RegExp(r'^\d{5}$'),
      postalExample: '75001',
      minLocalDigits: 9,
      maxLocalDigits: 9,
    ),
    CountryRule(
      code: 'BE',
      name: 'Belgique',
      dialCode: '+32',
      postalRegex: RegExp(r'^\d{4}$'),
      postalExample: '1000',
      minLocalDigits: 8,
      maxLocalDigits: 9,
    ),
    CountryRule(
      code: 'CH',
      name: 'Suisse',
      dialCode: '+41',
      postalRegex: RegExp(r'^\d{4}$'),
      postalExample: '1200',
      minLocalDigits: 9,
      maxLocalDigits: 9,
    ),
    CountryRule(
      code: 'DE',
      name: 'Allemagne',
      dialCode: '+49',
      postalRegex: RegExp(r'^\d{5}$'),
      postalExample: '10115',
      minLocalDigits: 7,
      maxLocalDigits: 11,
    ),
    CountryRule(
      code: 'ES',
      name: 'Espagne',
      dialCode: '+34',
      postalRegex: RegExp(r'^\d{5}$'),
      postalExample: '28001',
      minLocalDigits: 9,
      maxLocalDigits: 9,
    ),
    CountryRule(
      code: 'IT',
      name: 'Italie',
      dialCode: '+39',
      postalRegex: RegExp(r'^\d{5}$'),
      postalExample: '00118',
      minLocalDigits: 6,
      maxLocalDigits: 11,
      dropLeadingZeroForInternational: false,
    ),
    CountryRule(
      code: 'GB',
      name: 'Royaume-Uni',
      dialCode: '+44',
      postalRegex: RegExp(
        r'^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$',
        caseSensitive: false,
      ),
      postalExample: 'SW1A 1AA',
      minLocalDigits: 9,
      maxLocalDigits: 10,
    ),
    CountryRule(
      code: 'US',
      name: 'Etats-Unis',
      dialCode: '+1',
      postalRegex: RegExp(r'^\d{5}(-\d{4})?$'),
      postalExample: '90210',
      minLocalDigits: 10,
      maxLocalDigits: 10,
    ),
    CountryRule(
      code: 'CA',
      name: 'Canada',
      dialCode: '+1',
      postalRegex: RegExp(
        r'^[A-Z]\d[A-Z][ -]?\d[A-Z]\d$',
        caseSensitive: false,
      ),
      postalExample: 'H2Y 1C6',
      minLocalDigits: 10,
      maxLocalDigits: 10,
    ),
    CountryRule(
      code: 'MA',
      name: 'Maroc',
      dialCode: '+212',
      postalRegex: RegExp(r'^\d{5}$'),
      postalExample: '20000',
      minLocalDigits: 9,
      maxLocalDigits: 9,
    ),
    CountryRule(
      code: 'TN',
      name: 'Tunisie',
      dialCode: '+216',
      postalRegex: RegExp(r'^\d{4}$'),
      postalExample: '1000',
      minLocalDigits: 8,
      maxLocalDigits: 8,
    ),
  ];

  static List<CountryRule> get countries => _countries;

  static CountryRule countryByCode(String code) {
    return _countries.firstWhere(
      (c) => c.code == code,
      orElse: () => _countries.first,
    );
  }

  static String inferCountryCode({String? phone}) {
    final raw = normalize(phone ?? '').replaceAll(' ', '');
    if (!raw.startsWith('+')) return _countries.first.code;

    final ordered = [..._countries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in ordered) {
      if (raw.startsWith(country.dialCode)) {
        return country.code;
      }
    }
    return _countries.first.code;
  }

  static String applyDialCode(String value, String countryCode) {
    final country = countryByCode(countryCode);
    final digitsOnly = normalize(value).replaceAll(RegExp(r'\D'), '');

    var localDigits = digitsOnly;
    final ordered = [..._countries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final c in ordered) {
      final dialDigits = c.dialCode.replaceAll('+', '');
      if (localDigits.startsWith(dialDigits)) {
        localDigits = localDigits.substring(dialDigits.length);
        break;
      }
    }

    if (country.dropLeadingZeroForInternational && localDigits.startsWith('0')) {
      localDigits = localDigits.substring(1);
    }

    if (localDigits.isEmpty) {
      return country.dialCode;
    }
    return '${country.dialCode}$localDigits';
  }

  static String normalizePhoneForCountry(String value, String countryCode) {
    return applyDialCode(value, countryCode).replaceAll(' ', '');
  }

  static String normalizePostalCode(String value) {
    return normalize(value).toUpperCase();
  }

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r"\s+"), ' ');
  }

  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  static String? requiredText(String value, String label, {int? maxLength}) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return '$label est requis';
    if (maxLength != null && !hasMaxLength(normalized, maxLength)) {
      return '$label depasse $maxLength caracteres';
    }
    return null;
  }

  static String? strictText(
    String value,
    String label, {
    bool required = false,
    int maxLength = maxNameLength,
  }) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return required ? '$label est requis' : null;
    }
    if (!hasMaxLength(normalized, maxLength)) {
      return '$label depasse $maxLength caracteres';
    }
    if (!_strictTextRegex.hasMatch(normalized)) {
      return '$label ne doit contenir que des lettres, espaces, tirets ou apostrophes';
    }
    return null;
  }

  static String? email(String value, {bool required = false}) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return required ? 'Email est requis' : null;
    }
    if (!hasMaxLength(normalized, maxEmailLength)) {
      return 'Email depasse $maxEmailLength caracteres';
    }
    if (!_emailRegex.hasMatch(normalized)) {
      return 'Email invalide';
    }
    return null;
  }

  static String? phoneInternational(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (!hasMaxLength(normalized, maxPhoneLength)) {
      return 'Telephone depasse $maxPhoneLength caracteres';
    }
    if (!_phoneAllowedCharsRegex.hasMatch(normalized)) {
      return 'Telephone invalide';
    }
    final digitsCount = normalized.replaceAll(RegExp(r"\D"), '').length;
    if (digitsCount < 8 || digitsCount > 15) {
      return 'Telephone invalide (8 a 15 chiffres)';
    }
    return null;
  }

  static String? phoneForCountry(String value, String countryCode) {
    final country = countryByCode(countryCode);
    final normalized = normalize(value).replaceAll(' ', '');
    if (normalized.isEmpty) return null;

    if (!normalized.startsWith(country.dialCode)) {
      return 'Telephone doit commencer par ${country.dialCode}';
    }
    if (!RegExp(r'^\+[0-9]+$').hasMatch(normalized)) {
      return 'Telephone invalide';
    }

    final totalDigits = normalized.replaceAll(RegExp(r'\D'), '').length;
    final dialDigits = country.dialCode.replaceAll('+', '').length;
    final localDigits = totalDigits - dialDigits;
    if (localDigits < country.minLocalDigits ||
        localDigits > country.maxLocalDigits) {
      if (country.minLocalDigits == country.maxLocalDigits) {
        if (country.code == 'FR') {
          return 'Pour la France: 10 chiffres en national (0X...), ou ${country.dialCode} suivi de 9 chiffres';
        }
        return 'Telephone invalide pour ${country.name} (${country.minLocalDigits} chiffres apres ${country.dialCode})';
      }
      return 'Telephone invalide pour ${country.name} (${country.minLocalDigits} a ${country.maxLocalDigits} chiffres apres ${country.dialCode})';
    }
    return null;
  }

  static String? postalCodeInternational(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (normalized.length > maxPostalCodeLength) {
      return 'Code postal depasse $maxPostalCodeLength caracteres';
    }
    if (!_postalAllowedCharsRegex.hasMatch(normalized)) {
      return 'Code postal invalide';
    }
    final compact = normalized.replaceAll(RegExp(r"[^A-Za-z0-9]"), '');
    if (compact.length < 3 || compact.length > 10) {
      return 'Code postal invalide (3 a 10 caracteres alphanumeriques)';
    }
    return null;
  }

  static String? postalCodeForCountry(String value, String countryCode) {
    final country = countryByCode(countryCode);
    final normalized = normalizePostalCode(value);
    if (normalized.isEmpty) return null;
    if (normalized.length > maxPostalCodeLength) {
      return 'Code postal depasse $maxPostalCodeLength caracteres';
    }
    if (!_postalAllowedCharsRegex.hasMatch(normalized)) {
      return 'Code postal invalide';
    }
    if (!country.postalRegex.hasMatch(normalized)) {
      return 'Code postal invalide pour ${country.name} (ex: ${country.postalExample})';
    }
    return null;
  }

  static String? address(String value, {bool required = false}) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return required ? 'Adresse est requise' : null;
    }
    if (!hasMaxLength(normalized, maxAddressLength)) {
      return 'Adresse depasse $maxAddressLength caracteres';
    }
    return null;
  }

  static String? commentaire(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (!hasMaxLength(normalized, maxCommentLength)) {
      return 'Commentaire depasse $maxCommentLength caracteres';
    }
    return null;
  }

  static String? reference(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return 'Reference est requise';
    if (!hasMaxLength(normalized, 60)) return 'Reference depasse 60 caracteres';
    if (!_referenceRegex.hasMatch(normalized)) {
      return 'Reference invalide';
    }
    return null;
  }

  static String? designation(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return 'Designation est requise';
    if (!hasMaxLength(normalized, 120)) {
      return 'Designation depasse 120 caracteres';
    }
    return null;
  }

  static String? optionalText(String value, String label, int maxLength) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    if (!hasMaxLength(normalized, maxLength)) {
      return '$label depasse $maxLength caracteres';
    }
    return null;
  }

  static String? positiveDecimalRequired(String value, String label) {
    final normalized = normalize(value).replaceAll(',', '.');
    if (normalized.isEmpty) return '$label est requis';
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return '$label doit etre un nombre positif';
    }
    return null;
  }

  static String? nonNegativeDecimalOptional(String value, String label) {
    final normalized = normalize(value).replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return '$label doit etre un nombre positif ou nul';
    }
    return null;
  }

  static String? nonNegativeIntOptional(String value, String label) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return '$label doit etre un entier positif ou nul';
    }
    return null;
  }

  static String? minIntRequired(String value, String label, int min) {
    final normalized = normalize(value);
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < min) {
      return '$label doit etre un entier >= $min';
    }
    return null;
  }

  static String? yearOptional(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    final currentYear = DateTime.now().year + 1;
    if (parsed == null || parsed < 1900 || parsed > currentYear) {
      return 'Annee invalide';
    }
    return null;
  }
}

class CountryRule {
  const CountryRule({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.postalRegex,
    required this.postalExample,
    this.minLocalDigits = 6,
    this.maxLocalDigits = 12,
    this.dropLeadingZeroForInternational = true,
  });

  final String code;
  final String name;
  final String dialCode;
  final RegExp postalRegex;
  final String postalExample;
  final int minLocalDigits;
  final int maxLocalDigits;
  final bool dropLeadingZeroForInternational;
}
