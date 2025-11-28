import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/launch/splash_page.dart';

void main() {
  testWidgets('SplashPage builds', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SplashPage())),
    );
    expect(find.byType(SplashPage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 16));
  });
}
