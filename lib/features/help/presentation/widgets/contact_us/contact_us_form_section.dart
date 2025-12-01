import 'package:flutter/material.dart';

class ContactUsFormSection extends StatelessWidget {
  const ContactUsFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ContactTextField(
            label: 'Your Name',
            hintText: 'Enter your name',
            keyboardType: TextInputType.name,
          ),
          SizedBox(height: 12),
          _ContactTextField(
            label: 'Email Address',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          _ContactTextField(
            label: 'Subject',
            hintText: 'How can we help?',
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 12),
          _ContactMultilineField(label: 'Message', hintText: 'Your message...'),
        ],
      ),
    );
  }
}

class _ContactTextField extends StatelessWidget {
  const _ContactTextField({
    required this.label,
    required this.hintText,
    required this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: colors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactMultilineField extends StatelessWidget {
  const _ContactMultilineField({required this.label, required this.hintText});

  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: 5,
          minLines: 3,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: colors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
