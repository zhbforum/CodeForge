import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:mobile_app/features/auth/presentation/widgets/register_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key, this.returnTo = '/profile'});
  final String returnTo;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
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
    _confirm.dispose();
    super.dispose();
    _subAuth.close();
    _subVm.close();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(authViewModelProvider.notifier);

    try {
      await vm.signUpWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      final session = vm.currentSession;
      if (session != null) {
        context.go(widget.returnTo);
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Check and confirm your e-mail.')),
          );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SignUp error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/auth/login'),
            child: Text(
              'Sign In',
              style: text.titleSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's get you started on your coding journey.",
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                // Registration fields
                Form(
                  key: _formKey,
                  child: RegisterFields(
                    emailController: _email,
                    passwordController: _password,
                    confirmController: _confirm,
                    onSubmitted: _submit,
                  ),
                ),

                const SizedBox(height: 20),

                // button Sign Up
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading ? 'Creating...' : 'Sign Up',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'By signing up, you agree to our',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    // TODO(killursxlf): open Terms of Service
                  },
                  child: Text(
                    'Terms of Service',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SizedBox(height: 20),
    );
  }
}
