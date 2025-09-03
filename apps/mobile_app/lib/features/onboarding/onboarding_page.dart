import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'steps/name_step.dart';
part 'steps/reason_step.dart';
part 'steps/welcome_step.dart';
part 'widgets/companion_blink.dart';
part 'widgets/option_tile.dart';

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

  String _displayName(String value) {
    final compact = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return compact;
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final ctrl = ref.read(onboardingViewModelProvider.notifier);

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

          final raw = _nameCtrl.text;
          final nameForGreeting = _displayName(raw);

          ctrl.setName(nameForGreeting);

          final snack = SnackBar(
            content: Text('Nice to meet you, $nameForGreeting!'),
            duration: const Duration(milliseconds: 900),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          final controller = ScaffoldMessenger.of(context).showSnackBar(snack);
          await controller.closed;

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
        final maxBox =
            (isWide
                    ? math.min(c.maxWidth * 0.9, 640)
                    : math.min(c.maxWidth * 0.9, 460))
                .toDouble();

        final companionSize = isWide
            ? (c.maxWidth >= 720 ? 160.0 : 136.0)
            : 124.0;

        final Widget header = isWide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompanionBlink(
                    asset: 'assets/icons/companion.svg',
                    size: companionSize,
                    semanticsLabel: 'Onboarding companion',
                  ),
                  const SizedBox(width: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: _MessageCard(
                      text: message,
                      fill: cs.surfaceContainerHighest,
                      border: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompanionBlink(
                    asset: 'assets/icons/companion.svg',
                    size: companionSize,
                    semanticsLabel: 'Onboarding companion',
                  ),
                  const SizedBox(height: 10),
                  _MessageCard(
                    text: message,
                    fill: cs.surfaceContainerHighest,
                    border: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxBox),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      header,
                      const SizedBox(height: 20),
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
            ),

            if (primaryLabel != null && onPrimary != null)
              AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: FilledButton(
                      onPressed: onPrimary,
                      child: Text(primaryLabel!),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.text,
    required this.fill,
    required this.border,
  });

  final String text;
  final Color fill;
  final Color border;

  static const _radius = 28.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 18, vertical: 16);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: _padding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
        ),
      ),
    );
  }
}
