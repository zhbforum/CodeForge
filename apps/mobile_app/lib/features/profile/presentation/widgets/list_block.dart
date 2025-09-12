import 'package:flutter/material.dart';

class ListBlock extends StatelessWidget {
  const ListBlock({required this.items, super.key});
  final List<ListItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? cs.surfaceContainerHighest
          : cs.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              title: Text(items[i].title),
              trailing: const Icon(Icons.chevron_right),
              onTap: items[i].onTap,
              dense: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            if (!items[i].isLast)
              Divider(height: 1, thickness: 1, color: cs.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class ListItem {
  const ListItem({required this.title, this.onTap, this.isLast = false});

  final String title;
  final VoidCallback? onTap;
  final bool isLast;
}
