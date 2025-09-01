import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/core/routing/app_router.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:mobile_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds and shows onboarding', (tester) async {
    final testRouter = GoRouter(
      initialLocation: OnboardingPage.routePath,
      routes: [
        GoRoute(
          path: OnboardingPage.routePath,
          builder: (context, state) => const OnboardingPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(funAnimationsEnabled: false),
          ),
          appRouterProvider.overrideWithValue(testRouter),
        ],
        child: const App(),
      ),
    );

    for (var i = 0; i < 20; i++) {
      if (find.byType(OnboardingPage).evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(OnboardingPage), findsOneWidget);

    expect(find.byType(FilledButton), findsWidgets);
  });
}
