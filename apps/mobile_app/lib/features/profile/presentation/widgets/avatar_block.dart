import 'package:flutter/material.dart';

class AvatarBlock extends StatelessWidget {
  const AvatarBlock({required this.onEditAvatar, super.key, this.imageUrl});

  final String? imageUrl;
  final VoidCallback onEditAvatar;

  bool _isValidUrl(String? s) {
    final u = Uri.tryParse(s ?? '');
    return u != null && (u.isScheme('http') || u.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    final ok = _isValidUrl(imageUrl);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            backgroundImage: ok ? NetworkImage(imageUrl!) : null,
            child: ok
                ? null
                : Icon(
                    Icons.person,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: onEditAvatar,
              icon: const Icon(Icons.edit, size: 18),
              style: IconButton.styleFrom(shape: const CircleBorder()),
            ),
          ),
        ],
      ),
    );
  }
}
