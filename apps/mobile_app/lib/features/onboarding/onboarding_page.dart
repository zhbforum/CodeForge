import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/onboarding/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'widgets/speech_bubble.dart';
part 'widgets/curved_tail.dart';
part 'widgets/companion_blink.dart';
part 'widgets/option_tile.dart';
part 'steps/welcome_step.dart';
part 'steps/reason_step.dart';
part 'steps/name_step.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = (value ?? '').trim();
    if (v.length < 2 || v.length > 20) {
      return 'Name must be 2–20 characters';
    }
    final ok = RegExp(r"^[\p{L}\p{N}_\- '.]+$", unicode: true).hasMatch(v);
    if (!ok) return "Allowed: letters, digits, space, -, _, ', .";
    return null;
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final ctrl = ref.read(onboardingControllerProvider.notifier);

    final Widget body = switch (state.step) {
      OnbStep.welcome => _WelcomeStep(onLetsGo: ctrl.goToReason),
      OnbStep.reason => _ReasonStep(
        onPick: (code) {
          ctrl.chooseReason(code);
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Awesome — I’ll help you with that!'),
              ),
            );
        },
      ),
      OnbStep.name => _NameStep(
        formKey: _formKey,
        nameCtrl: _nameCtrl,
        nameFocus: _nameFocus,
        validator: _validateName,
        onSubmit: () async {
          if (!_formKey.currentState!.validate()) {
            _nameFocus.requestFocus();
            return;
          }
          ctrl.setName(_nameCtrl.text.trim());
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Nice to meet you!')));
          await _finish();
        },
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(state.step), child: body),
          ),
        ),
      ),
    );
  }
}

class _OnbFrame extends StatelessWidget {
  const _OnbFrame({
    required this.message,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
  });

  final String message;
  final Widget body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 420;
        final maxBox = math.min(c.maxWidth * 0.9, 460).toDouble();

        final bubble = _SpeechBubble(
          text: message,
          fill: cs.surfaceContainerHighest,
          border: cs.outlineVariant.withValues(alpha: 0.4),
          anchor: isWide ? .45 : .25,
        );

        final header = isWide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _CompanionBlink(asset: 'assets/icons/companion.svg'),
                  const SizedBox(width: 16),
                  Expanded(child: bubble),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _CompanionBlink(asset: 'assets/icons/companion.svg'),
                  const SizedBox(height: 12),
                  bubble,
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBox),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    header,
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (primaryLabel != null && onPrimary != null)
              AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FilledButton(
                  onPressed: onPrimary,
                  child: Text(primaryLabel!),
                ),
              ),
          ],
        );
      },
    );
  }
}
