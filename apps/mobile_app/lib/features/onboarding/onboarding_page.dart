import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CodeForge')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/onboarding'),
          child: const Text('Welcome to CodeForge!'),
        ),
      ),
    );
  }
}
