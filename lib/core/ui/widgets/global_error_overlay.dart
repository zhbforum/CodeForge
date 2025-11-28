import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/error/error_notifier.dart';

class GlobalErrorOverlay extends ConsumerWidget {
  const GlobalErrorOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appError = ref.watch(appErrorProvider);

    return Stack(
      children: [
        child,
        if (appError != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _ErrorToast(message: appError.message),
          ),
      ],
    );
  }
}

class _ErrorToast extends StatelessWidget {
  const _ErrorToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.error,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
