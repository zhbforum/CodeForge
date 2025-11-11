import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _NeverCompletingBundle extends CachingAssetBundle {
  final _never = Completer<ByteData>().future;
  @override
  Future<ByteData> load(String key) => _never;

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      Completer<String>().future;
}

void main() {
  testWidgets('CompanionBlink shows placeholder while SVG is unresolved', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _NeverCompletingBundle(),
        child: const ProviderScope(child: MaterialApp(home: OnboardingPage())),
      ),
    );

    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 50));

    final companion = find.bySemanticsLabel('Onboarding companion');
    expect(companion, findsOneWidget);

    final placeholder = find.descendant(
      of: companion,
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 0 && w.height == 0,
      ),
    );

    expect(placeholder, findsOneWidget);
  });
}
