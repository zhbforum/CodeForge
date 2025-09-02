import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum DailyGoal { casual10, regular30, pro60 }

enum AppThemeMode { system, light, dark }

enum AppIconStyle { classic, outline, gradient }

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(true) bool soundEnabled,
    @Default(false) bool remindersEnabled,
    @Default(9) int reminderHour,
    @Default(0) int reminderMinute,
    @Default(DailyGoal.casual10) DailyGoal dailyGoal,
    @Default(AppIconStyle.classic) AppIconStyle appIconStyle,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
