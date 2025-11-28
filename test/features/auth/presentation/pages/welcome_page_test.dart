import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:mobile_app/features/settings/presentation/widgets/settings_bottom_sheet.dart';

import '../../../../helpers/test_wrap.dart';

void main() {
  testWidgets('tapping settings icon opens SettingsBottomSheet', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const WelcomePage()));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SettingsBottomSheet), findsOneWidget);
  });

  testWidgets('Create account uses fallback /profile when returnTo is null', (
    tester,
  ) async {
    final calls = <String>[];

    await tester.pumpWidget(wrap(WelcomePage(onNavigate: calls.add)));

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(calls, hasLength(1));
    expect(calls.single, '/auth/signup?from=%2Fprofile');
  });

  testWidgets('Login uses provided returnTo when not empty', (tester) async {
    final calls = <String>[];

    await tester.pumpWidget(
      wrap(WelcomePage(returnTo: '/catalog', onNavigate: calls.add)),
    );

    await tester.tap(find.text('I already have an account'));
    await tester.pump();

    expect(calls, hasLength(1));
    expect(calls.single, '/auth/login?from=%2Fcatalog');
  });
}
