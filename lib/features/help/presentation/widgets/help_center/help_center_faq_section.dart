import 'package:flutter/material.dart';

class HelpCenterFaqSection extends StatelessWidget {
  const HelpCenterFaqSection({super.key});

  static const _faqs = <HelpCenterFaqItemData>[
    HelpCenterFaqItemData(
      icon: Icons.person,
      title: 'Account & Profile',
      description:
          'Questions about account creation,'
          ' password resets, and profile settings.',
    ),
    HelpCenterFaqItemData(
      icon: Icons.school,
      title: 'Courses & Learning',
      description:
          'Questions related to course progress, content, and language paths.',
    ),
    HelpCenterFaqItemData(
      icon: Icons.emoji_events,
      title: 'Gamification',
      description:
          'Questions explaining the rating system, seasons,'
          ' points, and leaderboards.',
    ),
    HelpCenterFaqItemData(
      icon: Icons.credit_card,
      title: 'Billing & Subscription',
      description:
          'Questions about payment, subscription management, and free trials.',
    ),
    HelpCenterFaqItemData(
      icon: Icons.build,
      title: 'Technical Support',
      description: 'Questions about app crashes, bugs, and performance issues.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (final item in _faqs)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: HelpCenterFaqItem(item: item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HelpCenterFaqItemData {
  const HelpCenterFaqItemData({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}

class HelpCenterFaqItem extends StatelessWidget {
  const HelpCenterFaqItem({required this.item, super.key});

  final HelpCenterFaqItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final borderColor = colors.outlineVariant;

    return Theme(
      data: theme.copyWith(dividerColor: borderColor),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        collapsedBackgroundColor: colors.surface,
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        leading: Icon(item.icon, color: colors.primary),
        title: Text(
          item.title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        iconColor: colors.onSurface,
        collapsedIconColor: colors.onSurface,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.description,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
