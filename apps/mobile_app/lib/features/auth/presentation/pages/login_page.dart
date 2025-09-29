import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:mobile_app/features/auth/presentation/widgets/login_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.returnTo = '/profile'});
  final String returnTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final ProviderSubscription<AsyncValue<AuthState>> _subAuth;
  late final ProviderSubscription<AsyncValue<void>> _subVm;

  @override
  void initState() {
    super.initState();

    _subAuth = ref.listenManual<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (prev, next) {
        final s = next.valueOrNull;
        if (s?.event == AuthChangeEvent.signedIn && mounted) {
          context.go(widget.returnTo);
        }
      },
      fireImmediately: false,
    );

    _subVm = ref.listenManual<AsyncValue<void>>(authViewModelProvider, (
      prev,
      next,
    ) {
      if (next is AsyncError && mounted) {
        final err = next.error;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth error: $err')));
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _subAuth.close();
    _subVm.close();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(authViewModelProvider.notifier);
    try {
      await vm.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      context.go(widget.returnTo);
    } catch (_) {}
  }

  Future<void> _oauth(OAuthProvider provider) async {
    try {
      await ref.read(authViewModelProvider.notifier).signInWithOAuth(provider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              children: [
                Form(
                  key: _formKey,
                  child: LoginFields(
                    emailController: _email,
                    passwordController: _password,
                    onSubmitted: _submit,
                  ),
                ),
                const SizedBox(height: 24),

                // Sign in button
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading ? 'Signing in...' : 'Sign In',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or continue with',
                        style: text.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: cs.outlineVariant)),
                  ],
                ),

                const SizedBox(height: 16),

                // OAuth
                _OAuthRow(
                  onGoogle: () => _oauth(OAuthProvider.google),
                  onGithub: () => _oauth(OAuthProvider.github),
                  onFacebook: () => _oauth(OAuthProvider.facebook),
                ),

                const SizedBox(height: 32),

                // Sign Up redirect
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'New here? ',
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: text.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: cs.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.go(
                              '/auth/signup?from=${widget.returnTo}',
                            ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthRow extends StatelessWidget {
  const _OAuthRow({
    required this.onGoogle,
    required this.onGithub,
    required this.onFacebook,
  });

  final VoidCallback onGoogle;
  final VoidCallback onGithub;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleIconButton(
          background: cs.surfaceContainerHighest,
          onTap: onGoogle,
          child: const FaIcon(FontAwesomeIcons.google),
        ),
        const SizedBox(width: 16),
        _CircleIconButton(
          background: cs.surfaceContainerHighest,
          onTap: onGithub,
          child: const FaIcon(FontAwesomeIcons.github),
        ),
        const SizedBox(width: 16),
        _CircleIconButton(
          background: cs.surfaceContainerHighest,
          onTap: onFacebook,
          child: const FaIcon(FontAwesomeIcons.facebook),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.child,
    required this.background,
    required this.onTap,
  });

  final Widget child;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: IconTheme(
            data: IconThemeData(color: cs.onSurface, size: 24),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
