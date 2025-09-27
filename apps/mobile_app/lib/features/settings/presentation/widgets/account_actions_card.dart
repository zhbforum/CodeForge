import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';

class AccountActionsCard extends ConsumerWidget {
  const AccountActionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final session =
        ref.watch(authStateStreamProvider).valueOrNull?.session ??
        ref.read(authViewModelProvider.notifier).currentSession;

    if (session == null) return const SizedBox.shrink();

    return Card(
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              final router = GoRouter.of(context);

              try {
                final rootNav = Navigator.of(context, rootNavigator: true);
                while (rootNav.canPop()) {
                  rootNav.pop();
                }
                await ref.read(authViewModelProvider.notifier).signOut();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  router.go('/welcome');
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Sign-out error: $e')));
                }
              }
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete account'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete account?'),
                  content: const Text(
                    'This action is irreversible.\n\n'
                    'Note: deleting a user directly from Supabase '
                    'requires a backend function/Service Role key. '
                    'Currently, this is just a confirmation.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (ok != true) return;

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Deletion is not implemented on client side.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
