import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:mobile_app/features/profile/presentation/widgets/avatar_block.dart';
import 'package:mobile_app/features/profile/presentation/widgets/friends_card.dart';
import 'package:mobile_app/features/profile/presentation/widgets/list_block.dart';
import 'package:mobile_app/features/profile/presentation/widgets/profile_edit_dialog.dart';
import 'package:mobile_app/features/profile/presentation/widgets/section_header.dart';
import 'package:mobile_app/features/settings/presentation/settings_bottom_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isAuthenticatedProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Profile')),
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
      body: SafeArea(
        child: profileState.when(
          loading: () => const _ProfileLoading(),
          error: (e, _) => _ProfileError(message: e.toString()),
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(),
                    SizedBox(height: 24),
                    _FriendsSection(),
                    SizedBox(height: 24),
                    _HelpSection(),
                    SizedBox(height: 24),
                    _GeneralSection(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: isLoggedIn
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    final from = Uri.encodeComponent('/profile');
                    context.push('/auth/login?from=$from');
                  },
                  child: const Text('Sign In'),
                ),
              ),
            ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final profile = ref.watch(profileProvider).valueOrNull;
    final fullName = (profile?.fullName?.trim().isNotEmpty ?? false)
        ? profile!.fullName!.trim()
        : 'Guest';
    final bio = profile?.bio;
    final avatarUrl = profile?.avatarUrl;
    final bioText = (bio?.isEmpty ?? true) ? 'Add a bio' : bio!;

    final needsSetup =
        (profile?.fullName == null || (profile?.fullName?.isEmpty ?? true)) ||
        (profile?.bio == null || (profile?.bio?.isEmpty ?? true));

    final seed = (profile?.username?.trim().isNotEmpty ?? false)
        ? profile!.username!.trim()
        : (profile?.id ?? 'guest');

    return Column(
      children: [
        AvatarBlock(
          imageUrl: avatarUrl,
          seed: seed,
          onEditAvatar: () {
            // TODO(killursxlf): picker + upload в
            // Supabase Storage + updateAvatar(url)
          },
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => ProfileEditDialog.show(context),
          borderRadius: BorderRadius.circular(8),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                bioText,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: () => ProfileEditDialog.show(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text('Edit Profile'),
            ),
          ),
        ),

        if (needsSetup) ...[
          const SizedBox(height: 12),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fill in your name and bio to complete your profile.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 220,
              height: 12,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 32),
            const SizedBox(height: 12),
            Text(
              'Failed to load profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Friends'),
        SizedBox(height: 8),
        FriendsCard(),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Help'),
        SizedBox(height: 8),
        ListBlock(
          items: [
            ListItem(title: 'Help Center'),
            ListItem(title: 'Frequently Asked Questions'),
            ListItem(title: 'Contact Support', isLast: true),
          ],
        ),
      ],
    );
  }
}

class _GeneralSection extends StatelessWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'General'),
        SizedBox(height: 8),
        ListBlock(
          items: [
            ListItem(title: 'About Us'),
            ListItem(title: 'Privacy Policy', isLast: true),
          ],
        ),
      ],
    );
  }
}
