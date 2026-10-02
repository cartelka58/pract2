class Validators {
  static String? required(String? v, {String label = 'Поле'}) {
    if (v == null || v.trim().isEmpty) return '$label обязательно';
    return null;
  }

  static String? lengthRange(
    String? v, {
    required int min,
    required int max,
    String label = 'Поле',
  }) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$label обязательно';
    if (s.length < min) return '$label: минимум $min символов';
    if (s.length > max) return '$label: максимум $max символов';
    return null;
  }

  static String? decimalRange(
    String? v, {
    required double min,
    required double max,
    String label = 'Значение',
  }) {
    if (v == null || v.trim().isEmpty) return '$label обязательно';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return '$label: должно быть число';
    if (n < min) return '$label: не менее $min';
    if (n > max) return '$label: не более $max';
    return null;
  }

  static String? intRange(
    String? v, {
    required int min,
    required int max,
    String label = 'Значение',
  }) {
    if (v == null || v.trim().isEmpty) return '$label обязательно';
    final n = int.tryParse(v.trim());
    if (n == null) return '$label: должно быть целое число';
    if (n < min) return '$label: не менее $min';
    if (n > max) return '$label: не более $max';
    return null;
  }

  static String? positiveInt(String? v, {String label = 'Количество'}) {
    return intRange(v, min: 1, max: 1000000, label: label);
  }

  static String? nonNegativeInt(String? v, {String label = 'Значение'}) {
    return intRange(v, min: 0, max: 1000000, label: label);
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email обязателен';
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!re.hasMatch(v.trim())) return 'Неверный формат email';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Телефон обязателен';
    final re = RegExp(r'^\+?[0-9\s\-()]{7,20}$');
    if (!re.hasMatch(v.trim())) return 'Неверный формат телефона';
    return null;
  }

  static String? sku(String? v) {
    if (v == null || v.trim().isEmpty) return 'Артикул обязателен';
    if (!RegExp(r'^FL-\d{3,5}$').hasMatch(v.trim())) {
      return 'Формат: FL-000';
    }
    return null;
  }

  static String? loyaltyCard(String? v) {
    if (v == null || v.trim().isEmpty) return 'Номер карты обязателен';
    if (!RegExp(r'^LC-\d{4}$').hasMatch(v.trim())) {
      return 'Формат: LC-0000';
    }
    return null;
  }
}
