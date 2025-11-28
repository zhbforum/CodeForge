import 'package:flutter/material.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';

class AvatarBlock extends StatelessWidget {
  const AvatarBlock({
    required this.onEditAvatar,
    required this.seed,
    super.key,
    this.imageUrl,
    this.radius = 64,
    this.showBorder = false,
  });

  final String? imageUrl;

  final String seed;

  final double radius;

  final bool showBorder;

  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(color: scheme.outlineVariant)
                  : null,
            ),
            child: GeneratedAvatar(size: size, seed: seed, url: imageUrl),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: onEditAvatar,
              icon: const Icon(Icons.edit, size: 18),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              tooltip: 'Edit avatar',
            ),
          ),
        ],
      ),
    );
  }
}
