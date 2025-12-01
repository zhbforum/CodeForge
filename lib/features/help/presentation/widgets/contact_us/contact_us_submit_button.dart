import 'package:flutter/material.dart';

class ContactUsSubmitButton extends StatelessWidget {
  const ContactUsSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            elevation: 1,
          ),
          onPressed: () {
            // TODO(killursxlf): Implement submit action
          },
          child: const Text('Send Message', overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
