import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';

class ProfileEditDialog extends ConsumerStatefulWidget {
  const ProfileEditDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ProfileEditDialog(),
    );
  }

  @override
  ConsumerState<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<ProfileEditDialog> {
  TextEditingController? _nameCtrl;
  TextEditingController? _bioCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null && _nameCtrl == null) {
      _nameCtrl = TextEditingController(text: profile.fullName ?? '');
      _bioCtrl = TextEditingController(text: profile.bio ?? '');
      if (mounted) setState(() {});
    }
  }

  Future<void> _save() async {
    if (_nameCtrl == null || _bioCtrl == null) return;

    setState(() => _saving = true);

    try {
      final notifier = ref.read(profileProvider.notifier);
      final name = _nameCtrl!.text.trim();
      final bio = _bioCtrl!.text.trim();
      final currentProfile = ref.read(profileProvider).valueOrNull;

      if (name != (currentProfile?.fullName ?? '')) {
        await notifier.updateFullName(name.isEmpty ? null : name);
      }

      if (bio != (currentProfile?.bio ?? '')) {
        await notifier.updateBio(bio.isEmpty ? null : bio);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.hasValue && _nameCtrl == null) {
      _initializeControllers();
    }

    if (_nameCtrl == null || _bioCtrl == null) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('Edit profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl!,
            decoration: const InputDecoration(labelText: 'Full name'),
            enabled: !_saving,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioCtrl!,
            decoration: const InputDecoration(labelText: 'Bio'),
            enabled: !_saving,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl?.dispose();
    _bioCtrl?.dispose();
    super.dispose();
  }
}
