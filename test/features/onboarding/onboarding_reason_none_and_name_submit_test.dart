import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/routing/app_router.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tap "None of these" then submit name with Done action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: OnboardingPage.routePath,
      routes: [
        GoRoute(
          path: OnboardingPage.routePath,
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Center(child: Text('HOME'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    final welcomeBtn = find.byType(FilledButton).first;
    expect(welcomeBtn, findsOneWidget);
    await tester.tap(welcomeBtn);
    await tester.pump(const Duration(milliseconds: 300));

    final noneTile = find.text('None of these');
    expect(noneTile, findsOneWidget);
    await tester.tap(noneTile);
    await tester.pump(const Duration(milliseconds: 300));

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);
    await tester.tap(nameField);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(nameField, 'Alex Tester');

    await tester.testTextInput.receiveAction(TextInputAction.done);

    var done = false;
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('onboarding_done') ?? false) {
        done = true;
        break;
      }
    }

    expect(
      done,
      isTrue,
      reason: 'Expected SharedPreferences["onboarding_done"] to be true',
    );
  });
}
