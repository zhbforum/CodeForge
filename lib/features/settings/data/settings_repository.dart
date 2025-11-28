import 'dart:convert';

import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _kKey = 'app.settings.json';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(s.toJson()));
  }
}
