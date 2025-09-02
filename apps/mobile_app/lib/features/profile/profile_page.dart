import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/settings/presentation/settings_bottom_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const SettingsBottomSheet(),
            ),
          ),
        ],
      ),
      body: const Center(child: Text('User profile')),
    );
  }
}
