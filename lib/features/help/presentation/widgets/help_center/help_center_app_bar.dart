import 'package:flutter/material.dart';

class HelpCenterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HelpCenterAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      elevation: 0,
      backgroundColor: colors.surface,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new),
        color: colors.onSurface,
      ),
      centerTitle: true,
      title: Text(
        'Help Centre',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
