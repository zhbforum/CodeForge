part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onLetsGo});
  final VoidCallback onLetsGo;

  @override
  Widget build(BuildContext context) {
    return _OnbFrame(
      message:
          'Welcome to CodeForge! I’m your blacksmith companion.\n'
          'To get you started, I’ll ask a couple of quick questions.',
      body: const SizedBox.shrink(),
      primaryLabel: 'Let’s go',
      onPrimary: onLetsGo,
    );
  }
}
