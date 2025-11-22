import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/legal/terms_of_service_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetKey = TermsOfServicePage.defaultAssetPath;

  ByteData byteDataFromString(String value) {
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);

    if (rootBundle is CachingAssetBundle) {
      (rootBundle as CachingAssetBundle).clear();
    }
  });

  group('TermsOfServicePage', () {
    testWidgets(
      'shows loading indicator then renders Markdown on successful load',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TermsOfServicePage(
              termsLoader: () async {
                return '# Terms of Service\n\nHello CodeForge!';
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final appBarTitleFinder = find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Terms of Service'),
        );
        expect(appBarTitleFinder, findsOneWidget);

        expect(find.byType(Markdown), findsOneWidget);
        expect(find.textContaining('Terms of Service'), findsWidgets);
        expect(find.textContaining('Hello CodeForge!'), findsOneWidget);
      },
    );

    testWidgets(
      'shows error message when terms loading fails (via injected termsLoader)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TermsOfServicePage(
              termsLoader: () async {
                throw Exception('Failed to load');
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Failed to load Terms of Service.'), findsOneWidget);
      },
    );

    testWidgets('uses default asset loader when no termsLoader is provided', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
          final key = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );

          if (key == assetKey) {
            return byteDataFromString(
              '# Terms of Service\n\nLoaded from default asset loader.',
            );
          }

          return null;
        },
      );

      await tester.pumpWidget(const MaterialApp(home: TermsOfServicePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(Markdown), findsOneWidget);
      expect(
        find.textContaining('Loaded from default asset loader.'),
        findsOneWidget,
      );
    });
  });
}
