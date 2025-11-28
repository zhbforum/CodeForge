import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = SettingsRepository();
  });

  group('SettingsRepository.load', () {
    test('returns parsed AppSettings when JSON is stored', () async {
      const stored = AppSettings();
      SharedPreferences.setMockInitialValues({
        'app.settings.json': jsonEncode(stored.toJson()),
      });

      final loaded = await repo.load();

      expect(loaded.toJson(), stored.toJson());
    });

    test('returns default when no value (sanity check)', () async {
      final loaded = await repo.load();
      expect(loaded.toJson(), const AppSettings().toJson());
    });
  });

  group('SettingsRepository.save', () {
    test('persists JSON and can be read back via load()', () async {
      const settings = AppSettings();

      await repo.save(settings);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('app.settings.json'),
        jsonEncode(settings.toJson()),
      );

      final roundtripped = await repo.load();
      expect(roundtripped.toJson(), settings.toJson());
    });
  });
}
