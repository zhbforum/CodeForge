import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/presentation/utils/auth_validators.dart';

class RegisterFields extends StatefulWidget {
  const RegisterFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSubmitted,
    this.autofill = true,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onSubmitted;
  final bool autofill;

  @override
  State<RegisterFields> createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) setState(() {});
  }

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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            autofillHints:
                widget.autofill ? const [AutofillHints.email] : null,
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
            obscureText: _obscure1,
            textInputAction: TextInputAction.next,
            autofillHints:
                widget.autofill ? const [AutofillHints.newPassword] : null,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock, color: cs.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure1 ? Icons.visibility : Icons.visibility_off,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.confirmController,
            autovalidateMode: widget.autovalidateMode,
            validator: (v) =>
                AuthValidators.confirm(v, widget.passwordController.text),
            obscureText: _obscure2,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
            autofillHints:
                widget.autofill ? const [AutofillHints.newPassword] : null,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock, color: cs.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure2 ? Icons.visibility : Icons.visibility_off,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
