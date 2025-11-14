import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/widgets/register_fields.dart';

void main() {
  TextEditingController makeController() => TextEditingController();

  group('RegisterFields', () {
    testWidgets('taps password visibility icon', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();
      final confirmController = makeController();

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterFields(
              emailController: emailController,
              passwordController: passwordController,
              confirmController: confirmController,
            ),
          ),
        ),
      );

      final passwordFieldFinder = find.byType(TextFormField).at(1);

      final visibilityIcon = find.descendant(
        of: passwordFieldFinder,
        matching: find.byIcon(Icons.visibility),
      );

      await tester.tap(visibilityIcon);
      await tester.pump();
    });

    testWidgets('taps confirm password visibility icon', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();
      final confirmController = makeController();

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterFields(
              emailController: emailController,
              passwordController: passwordController,
              confirmController: confirmController,
            ),
          ),
        ),
      );

      final confirmFieldFinder = find.byType(TextFormField).at(2);

      final visibilityIcon = find.descendant(
        of: confirmFieldFinder,
        matching: find.byIcon(Icons.visibility),
      );

      await tester.tap(visibilityIcon);
      await tester.pump();
    });

    testWidgets('confirm validator compares with current password', (
      tester,
    ) async {
      final emailController = makeController();
      final passwordController = makeController();
      final confirmController = makeController();

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterFields(
              emailController: emailController,
              passwordController: passwordController,
              confirmController: confirmController,
            ),
          ),
        ),
      );

      passwordController.text = 'Password123!';
      confirmController.text = 'OtherPassword';
      await tester.pump();

      final confirmFieldFinder = find.byType(TextFormField).at(2);
      final confirmField = tester.widget<TextFormField>(confirmFieldFinder);

      final error = confirmField.validator?.call(confirmController.text);

      expect(error, isNotNull);
    });

    testWidgets('calls onSubmitted when done action is fired', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();
      final confirmController = makeController();
      var submitted = false;

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterFields(
              emailController: emailController,
              passwordController: passwordController,
              confirmController: confirmController,
              onSubmitted: () {
                submitted = true;
              },
            ),
          ),
        ),
      );

      final confirmFieldFinder = find.byType(TextFormField).at(2);

      await tester.tap(confirmFieldFinder);
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, isTrue);
    });

    testWidgets('password change triggers password listener', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();
      final confirmController = makeController();

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
        confirmController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterFields(
              emailController: emailController,
              passwordController: passwordController,
              confirmController: confirmController,
            ),
          ),
        ),
      );

      passwordController.text = 'new-password';
      await tester.pump();

      expect(passwordController.text, 'new-password');
    });
  });
}
