import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:mobile_app/features/profile/presentation/widgets/avatar_block.dart';
import 'package:mobile_app/features/profile/presentation/widgets/friends_card.dart';
import 'package:mobile_app/features/profile/presentation/widgets/list_block.dart';
import 'package:mobile_app/features/profile/presentation/widgets/section_header.dart';
import 'package:mobile_app/features/settings/presentation/settings_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final isLoggedIn = ref.watch(isAuthenticatedProvider);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
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
    final String displayName = profile?.displayName ?? 'Guest';
    final String? bio = profile?.bio;
    final String? avatarUrl = profile?.avatarUrl;
    final String bioText = (bio?.isEmpty ?? true) ? 'Add a bio' : bio!;

    return Column(
      children: [
        AvatarBlock(
          imageUrl: avatarUrl,
          onEditAvatar: () {
            // TODO(killursxlf): picker + upload to Supabase Storage
          },
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // TODO(killursxlf): open bio editor
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bioText,
                style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.tonal(
            onPressed: () {
              // TODO(killursxlf): open profile edit screen
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text('Edit Profile'),
            ),
          ),
        ),
      ],
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
