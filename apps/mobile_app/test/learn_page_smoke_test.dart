import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/core/routing/app_router.dart';
import 'package:mobile_app/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('learn page shows grid of tracks', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(funAnimationsEnabled: false),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    final ctrl = container.read(onboardingViewModelProvider.notifier)
      ..goToReason();
    await tester.pump(const Duration(milliseconds: 100));
    ctrl.chooseReason('test');
    await tester.pump(const Duration(milliseconds: 100));

    final nameField = find.byType(TextFormField);
    expect(nameField, findsOneWidget);

    await tester.enterText(nameField, 'Alex');
    await tester.pump(const Duration(milliseconds: 16));

    final submitBtn = find.byType(FilledButton);
    expect(submitBtn, findsOneWidget);

    await tester.tap(submitBtn);

    for (var i = 0; i < 25; i++) {
      final appBarFound =
          find.byType(AppBar).evaluate().isNotEmpty &&
          find.text('Learn').evaluate().isNotEmpty;
      final gridFound = find.byType(GridView).evaluate().isNotEmpty;
      if (appBarFound || gridFound) break;
      await tester.pump(const Duration(milliseconds: 100));
    }

    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    expect(
      find.descendant(of: appBar, matching: find.text('Learn')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Full-Stack Developer'), findsOneWidget);
  });
}
