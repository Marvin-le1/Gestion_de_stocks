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
