import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/settings_controller.dart';
import 'package:mobile_app/features/settings/presentation/widgets/cyclic_time_picker.dart';
import 'package:mobile_app/features/settings/presentation/widgets/preview_option_tile.dart';
import 'package:mobile_app/features/settings/presentation/widgets/radio_group_compat.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              builder: (_) => const _SettingsHomeView(),
              settings: const RouteSettings(name: '/'),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsHomeView extends ConsumerWidget {
  const _SettingsHomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(settingsControllerProvider);

    return st.when(
      loading: () => const _SheetScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _SheetScaffold(body: Center(child: Text('Error: $e'))),
      data: (s) {
        final cs = Theme.of(context).colorScheme;

        return _SheetScaffold(
          title: 'Settings',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'App settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Card(
                color: cs.surfaceContainerLow,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Appearance'),
                      subtitle: Text(_themeLabel(s.themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _push(context, const _AppearanceView()),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Sound effects'),
                      value: s.soundEnabled,
                      onChanged: (v) => ref
                          .read(settingsControllerProvider.notifier)
                          .setSound(enabled: v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('App icon'),
                      subtitle: Text(_appIconLabel(s.appIconStyle)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _push(context, const _AppIconView()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Set goal'),
                      subtitle: Text(_goalLabel(s.dailyGoal)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _push(context, const _SetGoalView()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Card(
                color: cs.surfaceContainerLow,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Reminders'),
                      value: s.remindersEnabled,
                      onChanged: (v) => ref
                          .read(settingsControllerProvider.notifier)
                          .setReminders(enabled: v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Daily reminder time'),
                      subtitle: Text(
                        _formatTime(s.reminderHour, s.reminderMinute),
                      ),
                      trailing: TextButton(
                        child: const Text('Change'),
                        onPressed: () => _openTimePicker(context, ref, s),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _openTimePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings s,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        var h = s.reminderHour;
        var m = s.reminderMinute;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select time',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: CyclicTimePicker(
                    initialHour: s.reminderHour,
                    initialMinute: s.reminderMinute,
                    onChanged: (hh, mm) {
                      h = hh;
                      m = mm;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () async {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setReminderTime(h: h, m: m);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppearanceView extends ConsumerWidget {
  const _AppearanceView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();

    // Динамический размер превью: 28% от ширины, в пределах 92..140
    final w = MediaQuery.of(context).size.width;
    final imageSize = (w * 0.28).clamp(92.0, 140.0);

    return _SheetScaffold(
      title: 'Appearance',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Select Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          PreviewOptionTile(
            title: 'Use device settings',
            imageAsset: 'assets/icons/system.jpg',
            selected: s.themeMode == AppThemeMode.system,
            onTap: () => ref
                .read(settingsControllerProvider.notifier)
                .setTheme(mode: AppThemeMode.system),
            imageSize: imageSize,
          ),

          PreviewOptionTile(
            title: 'Light',
            imageAsset: 'assets/icons/light.jpg',
            selected: s.themeMode == AppThemeMode.light,
            onTap: () => ref
                .read(settingsControllerProvider.notifier)
                .setTheme(mode: AppThemeMode.light),
            imageSize: imageSize,
          ),

          PreviewOptionTile(
            title: 'Dark',
            imageAsset: 'assets/icons/dark.jpg',
            selected: s.themeMode == AppThemeMode.dark,
            onTap: () => ref
                .read(settingsControllerProvider.notifier)
                .setTheme(mode: AppThemeMode.dark),
            imageSize: imageSize,
          ),
        ],
      ),
    );
  }
}

class _AppIconView extends ConsumerWidget {
  const _AppIconView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();

    return _SheetScaffold(
      title: 'App icon',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: RadioGroupCompat<AppIconStyle>(
          groupValue: s.appIconStyle,
          onChanged: (style) => ref
              .read(settingsControllerProvider.notifier)
              .setAppIcon(style: style),
          options: const [
            RadioOption(AppIconStyle.classic, 'Classic'),
            RadioOption(AppIconStyle.outline, 'Outline'),
            RadioOption(AppIconStyle.gradient, 'Gradient'),
          ],
        ),
      ),
    );
  }
}

class _SetGoalView extends ConsumerWidget {
  const _SetGoalView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();

    return _SheetScaffold(
      title: 'Set goal',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much time do you want to spend learning?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            RadioGroupCompat<DailyGoal>(
              groupValue: s.dailyGoal,
              onChanged: (g) => ref
                  .read(settingsControllerProvider.notifier)
                  .setGoal(goal: g),
              options: const [
                RadioOption(DailyGoal.casual10, 'Casual — 10 min/day'),
                RadioOption(DailyGoal.regular30, 'Regular — 30 min/day'),
                RadioOption(DailyGoal.pro60, 'Pro developer — 60 min/day'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(int h, int m) =>
    '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

String _themeLabel(AppThemeMode m) => switch (m) {
  AppThemeMode.system => 'Device settings',
  AppThemeMode.light => 'Light',
  AppThemeMode.dark => 'Dark',
};

String _goalLabel(DailyGoal g) => switch (g) {
  DailyGoal.casual10 => 'Casual — 10 min/day',
  DailyGoal.regular30 => 'Regular — 30 min/day',
  DailyGoal.pro60 => 'Pro developer — 60 min/day',
};

String _appIconLabel(AppIconStyle s) => switch (s) {
  AppIconStyle.classic => 'Classic',
  AppIconStyle.outline => 'Outline',
  AppIconStyle.gradient => 'Gradient',
};

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.body, this.title});
  final String? title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final innerCanPop = Navigator.of(context).canPop();

    void closeSheet() {
      if (innerCanPop) {
        Navigator.of(context).maybePop();
      } else {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    }

    return Material(
      color: cs.surfaceContainerHighest,
      child: Column(
        children: [
          Row(
            children: [
              if (innerCanPop)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: Center(
                  child: Text(
                    title ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: closeSheet),
            ],
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
