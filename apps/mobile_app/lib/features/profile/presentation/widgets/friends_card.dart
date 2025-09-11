import 'package:flutter/material.dart';

class FriendsCard extends StatelessWidget {
  const FriendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? cs.surfaceContainerHighest
          : cs.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            Icon(
              Icons.group_add_outlined,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'You have no friends yet. Find them to compete and learn together!',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text('Add Friends'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
