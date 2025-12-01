import 'package:flutter/material.dart';

class ContactUsHeaderText extends StatelessWidget {
  const ContactUsHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        "Have any questions? We'd love to hear from you. "
        "Reach out and we'll get back to you shortly.",
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}
