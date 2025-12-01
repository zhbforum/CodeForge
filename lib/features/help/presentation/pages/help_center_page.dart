import 'package:flutter/material.dart';
import 'package:mobile_app/features/help/presentation/widgets/help_center/help_center_app_bar.dart';
import 'package:mobile_app/features/help/presentation/widgets/help_center/help_center_contact_section.dart';
import 'package:mobile_app/features/help/presentation/widgets/help_center/help_center_faq_section.dart';
import 'package:mobile_app/features/help/presentation/widgets/help_center/help_center_search_section.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const HelpCenterAppBar(),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpCenterSearchSection(),
              SizedBox(height: 16),
              HelpCenterFaqSection(),
              SizedBox(height: 16),
              HelpCenterContactSection(),
            ],
          ),
        ),
      ),
    );
  }
}
