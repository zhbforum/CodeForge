import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/settings/presentation/widgets/settings_bottom_sheet.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, this.returnTo, this.onNavigate});

  static const routePath = '/profile/welcome';

  final String? returnTo;
  final void Function(String location)? onNavigate;

  String get _fallbackReturn =>
      (returnTo?.isNotEmpty ?? false) ? returnTo! : '/profile';

  void _go(BuildContext context, String location) {
    final navigate = onNavigate ?? context.go;
    navigate(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (sheetContext) =>
                    SettingsBottomSheet(sheetContext: sheetContext),
              );
            },
          ),
        ],
      ),
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: SvgPicture.asset('assets/icons/companion.svg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sign in to view your profile',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your personal info, settings, and more.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => _go(
                      context,
                      '/auth/signup?from=${Uri.encodeComponent(_fallbackReturn)}',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _go(
                      context,
                      '/auth/login?from=${Uri.encodeComponent(_fallbackReturn)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
