// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  AppThemeMode get themeMode => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get remindersEnabled => throw _privateConstructorUsedError;
  int get reminderHour => throw _privateConstructorUsedError;
  int get reminderMinute => throw _privateConstructorUsedError;
  DailyGoal get dailyGoal => throw _privateConstructorUsedError;
  AppIconStyle get appIconStyle => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    AppThemeMode themeMode,
    bool soundEnabled,
    bool remindersEnabled,
    int reminderHour,
    int reminderMinute,
    DailyGoal dailyGoal,
    AppIconStyle appIconStyle,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? soundEnabled = null,
    Object? remindersEnabled = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? dailyGoal = null,
    Object? appIconStyle = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as AppThemeMode,
            soundEnabled: null == soundEnabled
                ? _value.soundEnabled
                : soundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            remindersEnabled: null == remindersEnabled
                ? _value.remindersEnabled
                : remindersEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderHour: null == reminderHour
                ? _value.reminderHour
                : reminderHour // ignore: cast_nullable_to_non_nullable
                      as int,
            reminderMinute: null == reminderMinute
                ? _value.reminderMinute
                : reminderMinute // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyGoal: null == dailyGoal
                ? _value.dailyGoal
                : dailyGoal // ignore: cast_nullable_to_non_nullable
                      as DailyGoal,
            appIconStyle: null == appIconStyle
                ? _value.appIconStyle
                : appIconStyle // ignore: cast_nullable_to_non_nullable
                      as AppIconStyle,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AppThemeMode themeMode,
    bool soundEnabled,
    bool remindersEnabled,
    int reminderHour,
    int reminderMinute,
    DailyGoal dailyGoal,
    AppIconStyle appIconStyle,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? soundEnabled = null,
    Object? remindersEnabled = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? dailyGoal = null,
    Object? appIconStyle = null,
  }) {
    return _then(
      _$AppSettingsImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as AppThemeMode,
        soundEnabled: null == soundEnabled
            ? _value.soundEnabled
            : soundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        remindersEnabled: null == remindersEnabled
            ? _value.remindersEnabled
            : remindersEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderHour: null == reminderHour
            ? _value.reminderHour
            : reminderHour // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderMinute: null == reminderMinute
            ? _value.reminderMinute
            : reminderMinute // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyGoal: null == dailyGoal
            ? _value.dailyGoal
            : dailyGoal // ignore: cast_nullable_to_non_nullable
                  as DailyGoal,
        appIconStyle: null == appIconStyle
            ? _value.appIconStyle
            : appIconStyle // ignore: cast_nullable_to_non_nullable
                  as AppIconStyle,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl({
    this.themeMode = AppThemeMode.system,
    this.soundEnabled = true,
    this.remindersEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.dailyGoal = DailyGoal.casual10,
    this.appIconStyle = AppIconStyle.classic,
  });

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  @JsonKey()
  final AppThemeMode themeMode;
  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool remindersEnabled;
  @override
  @JsonKey()
  final int reminderHour;
  @override
  @JsonKey()
  final int reminderMinute;
  @override
  @JsonKey()
  final DailyGoal dailyGoal;
  @override
  @JsonKey()
  final AppIconStyle appIconStyle;

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, soundEnabled: $soundEnabled, remindersEnabled: $remindersEnabled, reminderHour: $reminderHour, reminderMinute: $reminderMinute, dailyGoal: $dailyGoal, appIconStyle: $appIconStyle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.remindersEnabled, remindersEnabled) ||
                other.remindersEnabled == remindersEnabled) &&
            (identical(other.reminderHour, reminderHour) ||
                other.reminderHour == reminderHour) &&
            (identical(other.reminderMinute, reminderMinute) ||
                other.reminderMinute == reminderMinute) &&
            (identical(other.dailyGoal, dailyGoal) ||
                other.dailyGoal == dailyGoal) &&
            (identical(other.appIconStyle, appIconStyle) ||
                other.appIconStyle == appIconStyle));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    soundEnabled,
    remindersEnabled,
    reminderHour,
    reminderMinute,
    dailyGoal,
    appIconStyle,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings({
    final AppThemeMode themeMode,
    final bool soundEnabled,
    final bool remindersEnabled,
    final int reminderHour,
    final int reminderMinute,
    final DailyGoal dailyGoal,
    final AppIconStyle appIconStyle,
  }) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  AppThemeMode get themeMode;
  @override
  bool get soundEnabled;
  @override
  bool get remindersEnabled;
  @override
  int get reminderHour;
  @override
  int get reminderMinute;
  @override
  DailyGoal get dailyGoal;
  @override
  AppIconStyle get appIconStyle;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
