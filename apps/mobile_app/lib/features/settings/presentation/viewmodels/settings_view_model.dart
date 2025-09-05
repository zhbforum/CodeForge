import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/app_icon_service.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, AsyncValue<AppSettings>>((ref) {
      final repo = ref.watch(settingsRepositoryProvider);
      return SettingsViewModel(repo)..init();
    });

class SettingsViewModel extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsViewModel(this._repo) : super(const AsyncLoading());
  final SettingsRepository _repo;

  Future<void> init() async {
    try {
      final s = await _repo.load();
      state = AsyncData(s);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> update(AppSettings Function(AppSettings) recipe) async {
    final current = state.value ?? const AppSettings();
    final next = recipe(current);
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> setTheme({required AppThemeMode mode}) =>
      update((s) => s.copyWith(themeMode: mode));

  Future<void> setSound({required bool enabled}) =>
      update((s) => s.copyWith(soundEnabled: enabled));

  Future<void> setGoal({required DailyGoal goal}) =>
      update((s) => s.copyWith(dailyGoal: goal));

  Future<void> setReminderTime({required int h, required int m}) =>
      update((s) => s.copyWith(reminderHour: h, reminderMinute: m));

  Future<void> setReminders({required bool enabled}) =>
      update((s) => s.copyWith(remindersEnabled: enabled));

  Future<void> setAppIcon({required AppIconStyle style}) async {
    final prev = state.value ?? const AppSettings();
    final next = prev.copyWith(appIconStyle: style);

    state = AsyncData(next);

    try {
      final alias = switch (style) {
        AppIconStyle.classic => AppIconAlias.classic,
        AppIconStyle.outline => AppIconAlias.outline,
        AppIconStyle.gradient => AppIconAlias.gradient,
      };

      await AppIconService.switchIcon(alias);

      await _repo.save(next);
    } catch (e) {
      state = AsyncData(prev);
    }
  }
}
