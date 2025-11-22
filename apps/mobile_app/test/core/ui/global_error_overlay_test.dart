import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/error/error_notifier.dart';
import 'package:mobile_app/core/models/app_error.dart';
import 'package:mobile_app/core/ui/widgets/global_error_overlay.dart';

import '../../helpers/test_wrap.dart';

class _TestAppErrorNotifier extends AppErrorNotifier {
  _TestAppErrorNotifier(String message) : super() {
    state = AppError(message);
  }

  @override
  void show(String message) {
    state = AppError(message);
  }

  @override
  void clear() {
    state = null;
  }
}

void main() {
  group('GlobalErrorOverlay', () {
    testWidgets('renders only child when there is no global error', (
      tester,
    ) async {
      const childKey = Key('global-error-child');

      await tester.pumpWidget(
        wrap(const GlobalErrorOverlay(child: SizedBox(key: childKey))),
      );

      expect(find.byKey(childKey), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets(
      'renders error toast with message when appErrorProvider is not null',
      (tester) async {
        const childKey = Key('global-error-child');
        const errorMessage = 'Boom! Global error happened';

        await tester.pumpWidget(
          wrap(
            const GlobalErrorOverlay(child: SizedBox(key: childKey)),
            overrides: [
              appErrorProvider.overrideWith(
                (ref) => _TestAppErrorNotifier(errorMessage),
              ),
            ],
          ),
        );

        await tester.pump();

        expect(find.byKey(childKey), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);

        final positioned = tester.widget<Positioned>(
          find.ancestor(
            of: find.text(errorMessage),
            matching: find.byType(Positioned),
          ),
        );
        expect(positioned.top, 16);

        final textElement = tester.element(find.text(errorMessage));
        final theme = Theme.of(textElement);

        final materialFinder = find.ancestor(
          of: find.text(errorMessage),
          matching: find.byType(Material),
        );

        final material = tester
            .widgetList<Material>(materialFinder)
            .where((m) => m.elevation == 8)
            .single;

        expect(material.color, theme.colorScheme.error);
        expect(material.borderRadius, BorderRadius.circular(12));

        final rowFinder = find.ancestor(
          of: find.text(errorMessage),
          matching: find.byType(Row),
        );
        expect(rowFinder, findsOneWidget);

        final expandedFinder = find.ancestor(
          of: find.text(errorMessage),
          matching: find.byType(Expanded),
        );
        expect(expandedFinder, findsOneWidget);

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );
  });
}
