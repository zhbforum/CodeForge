import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/_app_icon_assets.dart';
import 'package:mobile_app/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:mobile_app/features/settings/presentation/widgets/cyclic_time_picker.dart';
import 'package:mobile_app/features/settings/presentation/widgets/preview_option_tile.dart';

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
    final st = ref.watch(settingsViewModelProvider);

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
                          .read(settingsViewModelProvider.notifier)
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
                          .read(settingsViewModelProvider.notifier)
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
                            .read(settingsViewModelProvider.notifier)
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
    final s = ref.watch(settingsViewModelProvider).value ?? const AppSettings();

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
                .read(settingsViewModelProvider.notifier)
                .setTheme(mode: AppThemeMode.system),
            imageSize: imageSize,
          ),
          PreviewOptionTile(
            title: 'Light',
            imageAsset: 'assets/icons/light.jpg',
            selected: s.themeMode == AppThemeMode.light,
            onTap: () => ref
                .read(settingsViewModelProvider.notifier)
                .setTheme(mode: AppThemeMode.light),
            imageSize: imageSize,
          ),
          PreviewOptionTile(
            title: 'Dark',
            imageAsset: 'assets/icons/dark.jpg',
            selected: s.themeMode == AppThemeMode.dark,
            onTap: () => ref
                .read(settingsViewModelProvider.notifier)
                .setTheme(mode: AppThemeMode.dark),
            imageSize: imageSize,
          ),
        ],
      ),
    );
  }
}

/// App Icon selection screen.
class _AppIconView extends ConsumerWidget {
  const _AppIconView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsViewModelProvider).value ?? const AppSettings();

    final w = MediaQuery.of(context).size.width;
    final imageSize = (w * 0.28).clamp(92.0, 140.0);

    void setStyle(AppIconStyle style) {
      ref.read(settingsViewModelProvider.notifier).setAppIcon(style: style);
    }

    return _SheetScaffold(
      title: 'App icon',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Select App Icon',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          for (final style in AppIconStyle.values)
            PreviewOptionTile(
              title: style.label,
              imageAsset: style.previewAsset,
              selected: s.appIconStyle == style,
              onTap: () => setStyle(style),
              imageSize: imageSize,
            ),
          PreviewOptionTile(
            title: 'Classic',
            imageAsset: 'assets/icons/companion.svg',
            selected: s.appIconStyle == AppIconStyle.classic,
            onTap: () => setStyle(AppIconStyle.classic),
            imageSize: imageSize,
          ),
          PreviewOptionTile(
            title: 'Outline',
            imageAsset: 'assets/icons/companion.svg',
            selected: s.appIconStyle == AppIconStyle.outline,
            onTap: () => setStyle(AppIconStyle.outline),
            imageSize: imageSize,
          ),
          PreviewOptionTile(
            title: 'Gradient',
            imageAsset: 'assets/icons/companion.svg',
            selected: s.appIconStyle == AppIconStyle.gradient,
            onTap: () => setStyle(AppIconStyle.gradient),
            imageSize: imageSize,
          ),
        ],
      ),
    );
  }
}

class _SetGoalView extends ConsumerWidget {
  const _SetGoalView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsViewModelProvider).value ?? const AppSettings();
    final vm = ref.read(settingsViewModelProvider.notifier);

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
            _GoalTile(
              label: 'Casual',
              minutesText: '10 min',
              selected: s.dailyGoal == DailyGoal.casual10,
              onChanged: () => vm.setGoal(goal: DailyGoal.casual10),
            ),
            _GoalTile(
              label: 'Regular',
              minutesText: '30 min',
              selected: s.dailyGoal == DailyGoal.regular30,
              onChanged: () => vm.setGoal(goal: DailyGoal.regular30),
            ),
            _GoalTile(
              label: 'Pro developer',
              minutesText: '60 min',
              selected: s.dailyGoal == DailyGoal.pro60,
              onChanged: () => vm.setGoal(goal: DailyGoal.pro60),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.label,
    required this.minutesText,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final String minutesText;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        button: true,
        label: '$label, $minutesText',
        onTap: onChanged,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onChanged,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _SelectionDot(selected: selected),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _GoalBadge(text: label),
                      const SizedBox(width: 8),
                      Text(
                        minutesText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Icon(Icons.check_rounded, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: selected ? 10 : 0,
          height: selected ? 10 : 0,
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _GoalBadge extends StatelessWidget {
  const _GoalBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w600,
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
  DailyGoal.casual10 => '10 min',
  DailyGoal.regular30 => '30 min',
  DailyGoal.pro60 => '60 min',
};

String _appIconLabel(AppIconStyle s) => s.label;

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
