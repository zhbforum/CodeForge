import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/widgets/login_fields.dart';

void main() {
  TextEditingController makeController() => TextEditingController();

  group('LoginFields', () {
    testWidgets('calls onSubmitted when done action is fired', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();
      var submitted = false;

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginFields(
              emailController: emailController,
              passwordController: passwordController,
              onSubmitted: () {
                submitted = true;
              },
            ),
          ),
        ),
      );

      final passwordFieldFinder = find.byType(TextFormField).at(1);

      await tester.tap(passwordFieldFinder);
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, isTrue);
    });

    testWidgets('taps password visibility icon', (tester) async {
      final emailController = makeController();
      final passwordController = makeController();

      addTearDown(() {
        emailController.dispose();
        passwordController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginFields(
              emailController: emailController,
              passwordController: passwordController,
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
  });
}
