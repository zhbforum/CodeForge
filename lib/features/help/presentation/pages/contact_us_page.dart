import 'package:flutter/material.dart';
import 'package:mobile_app/features/help/presentation/widgets/contact_us/contact_us_app_bar.dart';
import 'package:mobile_app/features/help/presentation/widgets/contact_us/contact_us_email_card.dart';
import 'package:mobile_app/features/help/presentation/widgets/contact_us/contact_us_form_section.dart';
import 'package:mobile_app/features/help/presentation/widgets/contact_us/contact_us_header_text.dart';
import 'package:mobile_app/features/help/presentation/widgets/contact_us/contact_us_submit_button.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const ContactUsAppBar(),
      body: const SafeArea(
        child: Column(
          children: [
            ContactUsHeaderText(),
            SizedBox(height: 8),
            ContactUsEmailCard(),
            SizedBox(height: 8),
            DividerWithOr(),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 16),
                child: ContactUsFormSection(),
              ),
            ),
            ContactUsSubmitButton(),
          ],
        ),
      ),
    );
  }
}

class DividerWithOr extends StatelessWidget {
  const DividerWithOr({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: colors.outlineVariant)),
          const SizedBox(width: 8),
          Text(
            'OR',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: colors.outlineVariant)),
        ],
      ),
    );
  }
}
