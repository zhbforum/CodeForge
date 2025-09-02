import 'package:flutter/material.dart';

class PreviewOptionTile extends StatelessWidget {
  const PreviewOptionTile({
    required this.title,
    required this.imageAsset,
    required this.selected,
    required this.onTap,
    super.key,

    this.subtitle,
    this.imageBorderRadius = 12,
    this.imageSize = 56,
  });

  final String title;
  final String? subtitle;
  final String imageAsset;
  final bool selected;
  final VoidCallback onTap;
  final double imageBorderRadius;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(imageBorderRadius),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: cs.surface,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    cacheWidth: (imageSize * 2).round(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: Icon(Icons.check_rounded, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
