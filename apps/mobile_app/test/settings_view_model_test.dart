import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/viewmodels/settings_view_model.dart';

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings _store = const AppSettings();
  AppSettings? lastSaved;

  @override
  Future<AppSettings> load() async => _store;

  @override
  Future<void> save(AppSettings s) async {
    _store = s;
    lastSaved = s;
  }
}

Future<T> _waitForValue<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final completer = Completer<T>();
  final sub = container.listen<AsyncValue<T>>(provider, (prev, next) {
    if (next.hasValue && !completer.isCompleted) {
      completer.complete(next.value as T);
    }
  }, fireImmediately: true);
  try {
    return await completer.future;
  } finally {
    sub.close();
  }
}

void main() {
  test('setTheme updates themeMode and persists via repository', () async {
    final fakeRepo = _FakeSettingsRepository();

    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);

    final initial = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    final target = initial.themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;

    await container
        .read(settingsViewModelProvider.notifier)
        .setTheme(mode: target);

    final updated = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    expect(updated.themeMode, target);
    expect(fakeRepo.lastSaved?.themeMode, target);
  });
}
