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

  testWidgets(
    'Reason pick shows snackbar (covers onPick) and narrow layout branch',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = GoRouter(
        initialLocation: OnboardingPage.routePath,
        routes: [
          GoRoute(
            path: OnboardingPage.routePath,
            builder: (_, __) => const OnboardingPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appRouterProvider.overrideWithValue(router)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 250));

      final welcomeBtn = find.byType(FilledButton).first;
      expect(welcomeBtn, findsOneWidget);

      await tester.tap(welcomeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final reasonStep = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_ReasonStep',
      );
      expect(reasonStep, findsOneWidget);

      var tappable = find.descendant(
        of: reasonStep,
        matching: find.byType(InkWell),
      );

      if (tappable.evaluate().isEmpty) {
        tappable = find.descendant(
          of: reasonStep,
          matching: find.byType(ListTile),
        );
      }

      if (tappable.evaluate().isEmpty) {
        tappable = find.descendant(
          of: reasonStep,
          matching: find.byType(GestureDetector),
        );
      }
      expect(tappable, findsWidgets);
      await tester.tap(tappable.first);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Awesome'), findsOneWidget);
    },
  );
}
