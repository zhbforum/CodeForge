import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';

void main() {
  test('AppSettings json round-trip', () {
    const s = AppSettings(
      themeMode: AppThemeMode.dark,
      soundEnabled: false,
      remindersEnabled: true,
      reminderHour: 10,
      reminderMinute: 30,
      dailyGoal: DailyGoal.pro60,
      appIconStyle: AppIconStyle.gradient,
    );

    final json = s.toJson();
    final restored = AppSettings.fromJson(json);

    expect(restored, equals(s));
  });
}
