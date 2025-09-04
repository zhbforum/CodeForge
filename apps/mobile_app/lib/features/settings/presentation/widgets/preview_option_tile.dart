import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                  child: _buildPreviewImage(context),
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

  Widget _buildPreviewImage(BuildContext context) {
    final isSvg = imageAsset.toLowerCase().endsWith('.svg');

    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final target = (imageSize * dpr).round();

    if (isSvg) {
      return SvgPicture.asset(imageAsset, fit: BoxFit.cover);
    }

    return Image.asset(
      imageAsset,
      fit: BoxFit.cover,
      cacheWidth: target,
      cacheHeight: target,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }
}
