import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';

void main() {
  group('AppSettings full coverage', () {
    test('defaults from factory and fromJson are equal', () {
      const a = AppSettings();
      final b = AppSettings.fromJson(const <String, dynamic>{});
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.themeMode, AppThemeMode.system);
      expect(a.soundEnabled, isTrue);
      expect(a.remindersEnabled, isFalse);
      expect(a.reminderHour, 9);
      expect(a.reminderMinute, 0);
      expect(a.dailyGoal, DailyGoal.casual10);
      expect(a.appIconStyle, AppIconStyle.classic);
    });

    test('copyWith updates all fields correctly', () {
      const base = AppSettings();
      final changed = base.copyWith(
        themeMode: AppThemeMode.dark,
        soundEnabled: false,
        remindersEnabled: true,
        reminderHour: 7,
        reminderMinute: 30,
        dailyGoal: DailyGoal.pro60,
        appIconStyle: AppIconStyle.gradient,
      );
      expect(changed == base, isFalse);
      expect(changed.themeMode, AppThemeMode.dark);
      expect(changed.soundEnabled, isFalse);
      expect(changed.remindersEnabled, isTrue);
      expect(changed.reminderHour, 7);
      expect(changed.reminderMinute, 30);
      expect(changed.dailyGoal, DailyGoal.pro60);
      expect(changed.appIconStyle, AppIconStyle.gradient);

      final same = base.copyWith(
        themeMode: AppThemeMode.dark,
        soundEnabled: false,
        remindersEnabled: true,
        reminderHour: 7,
        reminderMinute: 30,
        dailyGoal: DailyGoal.pro60,
        appIconStyle: AppIconStyle.gradient,
      );
      expect(same, equals(changed));
      expect(same.hashCode, equals(changed.hashCode));
    });

    test('toJson emits enum strings and is round-trippable', () {
      const original = AppSettings(
        themeMode: AppThemeMode.light,
        soundEnabled: false,
        remindersEnabled: true,
        reminderHour: 22,
        reminderMinute: 15,
        dailyGoal: DailyGoal.regular30,
        appIconStyle: AppIconStyle.outline,
      );

      final map = original.toJson();
      expect(map['themeMode'], 'light');
      expect(map['soundEnabled'], false);
      expect(map['remindersEnabled'], true);
      expect(map['reminderHour'], 22);
      expect(map['reminderMinute'], 15);
      expect(map['dailyGoal'], 'regular30');
      expect(map['appIconStyle'], 'outline');

      final withJunk = <String, dynamic>{...map, '__unknown': 123};
      final restored = AppSettings.fromJson(withJunk);
      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });
  });
}
