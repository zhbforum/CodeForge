import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/settings/presentation/widgets/settings_bottom_sheet.dart';

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 50),
  int maxTicks = 40,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Widget not visible: $finder');
}

void main() {
  testWidgets('SettingsBottomSheet opens', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (outerCtx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: outerCtx,
                      builder: (_) =>
                          SettingsBottomSheet(sheetContext: outerCtx),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));

    final sheetFinder = find.byType(SettingsBottomSheet);
    await pumpUntilVisible(tester, sheetFinder);

    expect(sheetFinder, findsOneWidget);

    Navigator.of(tester.element(sheetFinder)).pop();
    await tester.pump(const Duration(milliseconds: 200));
  });
}
