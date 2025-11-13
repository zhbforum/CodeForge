import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/viewmodels/settings_view_model.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({
    this.shouldThrowOnLoad = false,
    this.shouldThrowOnSave = false,
    AppSettings? initial,
  }) : _store = initial ?? const AppSettings();

  AppSettings _store;
  AppSettings? lastSaved;

  final bool shouldThrowOnLoad;
  final bool shouldThrowOnSave;

  @override
  Future<AppSettings> load() async {
    if (shouldThrowOnLoad) {
      throw Exception('load failed');
    }
    return _store;
  }

  @override
  Future<void> save(AppSettings s) async {
    if (shouldThrowOnSave) {
      throw Exception('save failed');
    }
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

Future<AsyncError<T>> _waitForError<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) async {
  final completer = Completer<AsyncError<T>>();
  final sub = container.listen<AsyncValue<T>>(provider, (prev, next) {
    if (next is AsyncError<T> && !completer.isCompleted) {
      completer.complete(next);
    }
  }, fireImmediately: true);
  try {
    return await completer.future;
  } finally {
    sub.close();
  }
}

ProviderContainer _createContainer(_FakeSettingsRepository repo) {
  return ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  test('setTheme updates themeMode and persists via repository', () async {
    final fakeRepo = _FakeSettingsRepository();
    final container = _createContainer(fakeRepo);
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

  test('setSound updates soundEnabled and persists via repository', () async {
    final fakeRepo = _FakeSettingsRepository();
    final container = _createContainer(fakeRepo);
    addTearDown(container.dispose);

    final initial = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    final target = !initial.soundEnabled;

    await container
        .read(settingsViewModelProvider.notifier)
        .setSound(enabled: target);

    final updated = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    expect(updated.soundEnabled, target);
    expect(fakeRepo.lastSaved?.soundEnabled, target);
  });

  test('setGoal updates dailyGoal and persists via repository', () async {
    final fakeRepo = _FakeSettingsRepository();
    final container = _createContainer(fakeRepo);
    addTearDown(container.dispose);

    final initial = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    final notifier = container.read(settingsViewModelProvider.notifier);

    final targetGoal = initial.dailyGoal;

    await notifier.setGoal(goal: targetGoal);

    final updated = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    expect(updated.dailyGoal, targetGoal);
    expect(fakeRepo.lastSaved?.dailyGoal, targetGoal);
  });

  test(
    'setReminderTime updates hour/minute and persists via repository',
    () async {
      final fakeRepo = _FakeSettingsRepository();
      final container = _createContainer(fakeRepo);
      addTearDown(container.dispose);

      await _waitForValue<AppSettings>(container, settingsViewModelProvider);

      final notifier = container.read(settingsViewModelProvider.notifier);

      const h = 9;
      const m = 30;

      await notifier.setReminderTime(h: h, m: m);

      final updated = await _waitForValue<AppSettings>(
        container,
        settingsViewModelProvider,
      );

      expect(updated.reminderHour, h);
      expect(updated.reminderMinute, m);
      expect(fakeRepo.lastSaved?.reminderHour, h);
      expect(fakeRepo.lastSaved?.reminderMinute, m);
    },
  );

  test(
    'setReminders updates remindersEnabled and persists via repository',
    () async {
      final fakeRepo = _FakeSettingsRepository();
      final container = _createContainer(fakeRepo);
      addTearDown(container.dispose);

      await _waitForValue<AppSettings>(container, settingsViewModelProvider);

      final notifier = container.read(settingsViewModelProvider.notifier);

      await notifier.setReminders(enabled: true);

      final updated = await _waitForValue<AppSettings>(
        container,
        settingsViewModelProvider,
      );

      expect(updated.remindersEnabled, isTrue);
      expect(fakeRepo.lastSaved?.remindersEnabled, isTrue);
    },
  );

  test('setAppIcon updates appIconStyle and persists via repository', () async {
    final fakeRepo = _FakeSettingsRepository();
    final container = _createContainer(fakeRepo);
    addTearDown(container.dispose);

    await _waitForValue<AppSettings>(container, settingsViewModelProvider);

    final notifier = container.read(settingsViewModelProvider.notifier);

    for (final style in AppIconStyle.values) {
      await notifier.setAppIcon(style: style);

      final updated = await _waitForValue<AppSettings>(
        container,
        settingsViewModelProvider,
      );

      expect(updated.appIconStyle, style);
      expect(fakeRepo.lastSaved?.appIconStyle, style);
    }
  });

  test('setAppIcon reverts state when save throws', () async {
    final failingRepo = _FakeSettingsRepository(shouldThrowOnSave: true);
    final container = _createContainer(failingRepo);
    addTearDown(container.dispose);

    final initial = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    final notifier = container.read(settingsViewModelProvider.notifier);

    await notifier.setAppIcon(style: AppIconStyle.gradient);

    final current = await _waitForValue<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    expect(current, equals(initial));
    expect(failingRepo.lastSaved, isNull);
  });

  test('init sets AsyncError when repository.load throws', () async {
    final failingRepo = _FakeSettingsRepository(shouldThrowOnLoad: true);
    final container = _createContainer(failingRepo);
    addTearDown(container.dispose);

    final error = await _waitForError<AppSettings>(
      container,
      settingsViewModelProvider,
    );

    expect(error.hasError, isTrue);
  });
}
