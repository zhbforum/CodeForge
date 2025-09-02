import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:mobile_app/features/onboarding/presentation/viewmodels/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
}

Future<void> _pumpOnboarding(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  final router = _buildRouter();

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Future<void> _jumpToNameStep(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  container.read(onboardingControllerProvider.notifier)
    ..goToReason()
    ..chooseReason('test');

  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('name validation shows error for short input', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(funAnimationsEnabled: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpOnboarding(tester, container: container);
    await _jumpToNameStep(tester, container: container);

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);

    await tester.enterText(nameField, 'A');
    await tester.pump(const Duration(milliseconds: 16));

    final submitBtn = find.byType(FilledButton);
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Name must be 2–20 characters'), findsOneWidget);
  });

  testWidgets('shows personalized SnackBar with normalized name', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(funAnimationsEnabled: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpOnboarding(tester, container: container);
    await _jumpToNameStep(tester, container: container);

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);

    await tester.enterText(nameField, '  Alex   Johnson  ');
    await tester.pump(const Duration(milliseconds: 16));

    final submitBtn = find.byType(FilledButton);
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);

    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Nice to meet you, Alex Johnson!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));

    var navigated = false;
    for (var i = 0; i < 20; i++) {
      if (find.text('Home').evaluate().isNotEmpty) {
        navigated = true;
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      navigated,
      isTrue,
      reason: 'Expected to navigate to /home after SnackBar closed',
    );
    expect(find.text('Home'), findsOneWidget);
  });
}
