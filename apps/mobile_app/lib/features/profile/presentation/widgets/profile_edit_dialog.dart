import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:mobile_app/features/profile/utils/profile_validators.dart';

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
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameCtrl;
  TextEditingController? _bioCtrl;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initializeControllers(),
    );
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final notifier = ref.read(profileProvider.notifier);
      final normalizedName = ProfileValidators.normalizeName(_nameCtrl!.text);
      final normalizedBio = ProfileValidators.normalizeBio(_bioCtrl!.text);
      final current = ref.read(profileProvider).valueOrNull;
      if (normalizedName != (current?.fullName ?? '')) {
        await notifier.updateFullName(
          normalizedName.isEmpty ? null : normalizedName,
        );
      }
      if (normalizedBio != (current?.bio ?? '')) {
        await notifier.updateBio(normalizedBio.isEmpty ? null : normalizedBio);
      }
      if (mounted) Navigator.pop(context);
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
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Full name',
                hintText: 'Your name',
              ),
              inputFormatters: <TextInputFormatter>[
                ProfileValidators.nameFilter,
                LengthLimitingTextInputFormatter(ProfileValidators.nameMax),
              ],
              maxLength: ProfileValidators.nameMax,
              validator: (v) => ProfileValidators.validateFullName(v ?? ''),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioCtrl,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell something about yourself',
              ),
              maxLines: 3,
              maxLength: ProfileValidators.bioMax,
              validator: (v) => ProfileValidators.validateBio(v ?? ''),
            ),
          ],
        ),
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
