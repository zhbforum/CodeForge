import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/settings/data/settings_repository.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:mobile_app/features/settings/presentation/widgets/cyclic_time_picker.dart';
import 'package:mobile_app/features/settings/presentation/widgets/preview_option_tile.dart';
import 'package:mobile_app/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 50),
  int maxTicks = 40,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Widget not visible: $finder');
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository(this._settings);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}

class _FakeSettingsViewModel extends SettingsViewModel {
  _FakeSettingsViewModel(AppSettings initial)
    : _initial = initial,
      super(_FakeSettingsRepository(initial)) {
    state = AsyncValue.data(initial);
  }

  final AppSettings _initial;

  AppSettings get _current => state.value ?? _initial;

  void _update(AppSettings next) {
    state = AsyncValue.data(next);
  }

  @override
  Future<void> setSound({required bool enabled}) async {
    _update(_current.copyWith(soundEnabled: enabled));
  }

  @override
  Future<void> setReminders({required bool enabled}) async {
    _update(_current.copyWith(remindersEnabled: enabled));
  }

  @override
  Future<void> setReminderTime({required int h, required int m}) async {
    _update(_current.copyWith(reminderHour: h, reminderMinute: m));
  }

  @override
  Future<void> setTheme({required AppThemeMode mode}) async {
    _update(_current.copyWith(themeMode: mode));
  }

  @override
  Future<void> setAppIcon({required AppIconStyle style}) async {
    _update(_current.copyWith(appIconStyle: style));
  }

  @override
  Future<void> setGoal({required DailyGoal goal}) async {
    _update(_current.copyWith(dailyGoal: goal));
  }
}

class _ErrorSettingsViewModel extends SettingsViewModel {
  _ErrorSettingsViewModel()
    : super(_FakeSettingsRepository(const AppSettings())) {
    state = AsyncValue.error('Boom', StackTrace.current);
  }
}

class _MockAuthRepository extends Mock implements AuthRepository {}

Widget _buildApp({
  required AppSettings settings,
  required bool isAuthenticated,
}) {
  return ProviderScope(
    overrides: [
      settingsViewModelProvider.overrideWith(
        (ref) => _FakeSettingsViewModel(settings),
      ),
      isAuthenticatedProvider.overrideWith((ref) => isAuthenticated),
      authRepositoryProvider.overrideWith((ref) => _MockAuthRepository()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (outerCtx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                SettingsBottomSheet.show<void>(outerCtx);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  const base = AppSettings();
  final initial = base.copyWith(
    soundEnabled: false,
    remindersEnabled: true,
    reminderHour: 8,
    reminderMinute: 30,
    dailyGoal: DailyGoal.casual10,
    themeMode: AppThemeMode.system,
  );

  testWidgets('SettingsBottomSheet opens via static show()', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));

    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);

    expect(sheetFinder, findsOneWidget);

    Navigator.of(tester.element(sheetFinder), rootNavigator: true).pop();
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('main view shows sections when authenticated', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App settings'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);
    expect(find.text('Set goal'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Daily reminder time'), findsOneWidget);
  });

  testWidgets('toggling sound effects switch updates UI', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    final soundTileFinder = find.byWidgetPredicate(
      (w) =>
          w is SwitchListTile &&
          w.title is Text &&
          (w.title! as Text).data == 'Sound effects',
    );

    var tile = tester.widget<SwitchListTile>(soundTileFinder);
    expect(tile.value, isFalse);

    await tester.tap(soundTileFinder);
    await tester.pumpAndSettle();

    tile = tester.widget<SwitchListTile>(soundTileFinder);
    expect(tile.value, isTrue);
  });

  testWidgets('toggling reminders switch updates UI', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    final remindersTileFinder = find.byWidgetPredicate(
      (w) =>
          w is SwitchListTile &&
          w.title is Text &&
          (w.title! as Text).data == 'Reminders',
    );

    var tile = tester.widget<SwitchListTile>(remindersTileFinder);
    expect(tile.value, isTrue);

    await tester.tap(remindersTileFinder);
    await tester.pumpAndSettle();

    tile = tester.widget<SwitchListTile>(remindersTileFinder);
    expect(tile.value, isFalse);
  });

  testWidgets('open Appearance view and tap theme options', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Select Appearance'), findsOneWidget);
    expect(find.text('Use device settings'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    final tiles = find.byType(PreviewOptionTile);
    expect(tiles, findsNWidgets(3));

    await tester.tap(tiles.at(0));
    await tester.pumpAndSettle();

    await tester.tap(tiles.at(1));
    await tester.pumpAndSettle();

    await tester.tap(tiles.at(2));
    await tester.pumpAndSettle();
  });

  testWidgets('open App icon view, tap icon options', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('App icon'));
    await tester.pumpAndSettle();

    expect(find.text('App icon'), findsOneWidget);
    expect(find.text('Select App Icon'), findsOneWidget);

    final iconTiles = find.byType(PreviewOptionTile);
    expect(iconTiles, findsWidgets);

    await tester.tap(iconTiles.first);
    await tester.pumpAndSettle();
  });

  testWidgets('open Set goal view and select different goals', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set goal'));
    await tester.pumpAndSettle();

    expect(find.text('Set goal'), findsOneWidget);
    expect(
      find.text('How much time do you want to spend learning?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Casual'), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Regular'), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pro developer'), warnIfMissed: false);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'open time picker, change value via onChanged and press Save closes sheet',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildApp(settings: initial, isAuthenticated: true),
      );

      await tester.tap(find.text('Open'));
      final sheetFinder = find.byType(SettingsBottomSheet);
      await pumpUntilVisible(tester, sheetFinder);
      await tester.pumpAndSettle();

      final changeButton = find.text('Change');

      await tester.scrollUntilVisible(changeButton, 100);
      await tester.pumpAndSettle();

      await tester.tap(changeButton);
      await tester.pumpAndSettle();

      final timePickerFinder = find.byType(CyclicTimePicker);
      expect(timePickerFinder, findsOneWidget);

      final timePicker = tester.widget<CyclicTimePicker>(timePickerFinder);
      timePicker.onChanged(9, 45);

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(saveButton, findsNothing);
    },
  );

  testWidgets('open time picker and press Cancel closes inner sheet', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    final changeButton = find.text('Change');

    await tester.scrollUntilVisible(changeButton, 100);
    await tester.pumpAndSettle();

    await tester.tap(changeButton);
    await tester.pumpAndSettle();

    expect(find.text('Select time'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Select time'), findsNothing);
  });

  testWidgets('header close button dismisses settings sheet', (tester) async {
    await tester.pumpWidget(
      _buildApp(settings: initial, isAuthenticated: true),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('error state shows error scaffold', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsViewModelProvider.overrideWith(
            (ref) => _ErrorSettingsViewModel(),
          ),
          isAuthenticatedProvider.overrideWith((ref) => true),
          authRepositoryProvider.overrideWith((ref) => _MockAuthRepository()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (outerCtx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    SettingsBottomSheet.show<void>(outerCtx);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });
}
