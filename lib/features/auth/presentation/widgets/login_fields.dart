import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/presentation/utils/auth_validators.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({
    required this.emailController,
    required this.passwordController,
    super.key,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSubmitted,
    this.autofill = true,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onSubmitted;
  final bool autofill;

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
    );

    return Theme(
      data: theme.copyWith(inputDecorationTheme: inputTheme),
      child: Column(
        children: [
          TextFormField(
            controller: widget.emailController,
            autovalidateMode: widget.autovalidateMode,
            validator: AuthValidators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: widget.autofill ? const [AutofillHints.email] : null,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.mail, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.passwordController,
            autovalidateMode: widget.autovalidateMode,
            validator: AuthValidators.password,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
            autofillHints: widget.autofill
                ? const [AutofillHints.password]
                : null,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock, color: cs.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
