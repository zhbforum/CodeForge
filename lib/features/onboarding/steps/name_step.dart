part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.formKey,
    required this.nameCtrl,
    required this.nameFocus,
    required this.validator,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final FocusNode nameFocus;
  final String? Function(String?) validator;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _OnbFrame(
      message: 'What’s your name?',
      body: Form(
        key: formKey,
        child: TextFormField(
          controller: nameCtrl,
          focusNode: nameFocus,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: 20,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'Example, Alex',
          ),
          validator: validator,
          onFieldSubmitted: (_) => onSubmit(),
        ),
      ),
      primaryLabel: 'Continue',
      onPrimary: onSubmit,
    );
  }
}
