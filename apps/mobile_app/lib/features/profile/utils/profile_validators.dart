import 'package:flutter/services.dart';

class ProfileValidators {
  static const int nameMax = 50;
  static const int bioMax = 200;

  static final RegExp nameAllowed = RegExp(
    r"[A-Za-z0-9À-ÖØ-öø-ÿĀ-žА-Яа-яЁёІіЇїȘșȚțÄÖÜäöüß .'\-]",
    unicode: true,
  );

  static final FilteringTextInputFormatter nameFilter =
      FilteringTextInputFormatter.allow(nameAllowed);

  static String? validateFullName(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return 'Name is required';
    if (name.length > nameMax) return 'Max $nameMax characters';
    if (!RegExp('^${nameAllowed.pattern}+\$', unicode: true).hasMatch(name)) {
      return "Only letters, numbers, spaces, '.', '-' and \"'\"";
    }
    return null;
  }

  static String? validateBio(String raw) {
    final bio = raw.trim();
    if (bio.length > bioMax) return 'Max $bioMax characters';
    if (RegExp(r'[\u0000-\u001F\u007F]').hasMatch(bio)) {
      return 'Control characters are not allowed';
    }
    return null;
  }

  static String normalizeName(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizeBio(String raw) => raw.trim();
}
