// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
              AppThemeMode.system,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 9,
      reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      dailyGoal: $enumDecodeNullable(_$DailyGoalEnumMap, json['dailyGoal']) ??
          DailyGoal.casual10,
      appIconStyle:
          $enumDecodeNullable(_$AppIconStyleEnumMap, json['appIconStyle']) ??
              AppIconStyle.classic,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'soundEnabled': instance.soundEnabled,
      'remindersEnabled': instance.remindersEnabled,
      'reminderHour': instance.reminderHour,
      'reminderMinute': instance.reminderMinute,
      'dailyGoal': _$DailyGoalEnumMap[instance.dailyGoal]!,
      'appIconStyle': _$AppIconStyleEnumMap[instance.appIconStyle]!,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};

const _$DailyGoalEnumMap = {
  DailyGoal.casual10: 'casual10',
  DailyGoal.regular30: 'regular30',
  DailyGoal.pro60: 'pro60',
};

const _$AppIconStyleEnumMap = {
  AppIconStyle.classic: 'classic',
  AppIconStyle.outline: 'outline',
  AppIconStyle.gradient: 'gradient',
};
