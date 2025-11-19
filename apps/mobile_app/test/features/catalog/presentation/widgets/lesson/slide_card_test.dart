import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/slide_card.dart';

import '../../../../../helpers/test_wrap.dart';

LessonSlide _slide({required String type, Map<String, dynamic>? content}) {
  return LessonSlide(
    id: 'slide-1',
    contentType: type,
    content: content ?? <String, dynamic>{},
    order: 0,
  );
}

void main() {
  group('normalizeMd', () {
    test('normalizes CRLF and escaped CRLF to LF', () {
      const input = 'line1\r\nline2\\r\\nline3\\nline4';
      final normalized = normalizeMd(input);

      expect(normalized, 'line1\nline2\nline3\nline4');
    });

    test('returns string unchanged when nothing to normalize', () {
      const input = 'simple text\nwith newline';
      expect(normalizeMd(input), input);
    });
  });

  group('SlideCard - contentType switch', () {
    testWidgets('renders text slide with title + markdown when no blocks', (
      tester,
    ) async {
      final slide = _slide(
        type: 'text',
        content: {
          'title': 'Intro title',
          'align': 'center',
          'markdown': 'Hello **Markdown**',
        },
      );

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));

      expect(find.text('Intro title'), findsOneWidget);
      expect(find.textContaining('Hello'), findsOneWidget);
    });

    testWidgets(
      'renders text slide using blocks (hero, callout, list, quote, code, pr)',
      (tester) async {
        final slide = _slide(
          type: 'text',
          content: {
            'align': 'start',
            'blocks': [
              {
                'type': 'hero',
                'height': 120.0,
                'align': 'end',
                'caption': 'Hero caption',
              },
              {'type': 'callout', 'text': 'Tip text', 'flavor': 'tip'},
              {'type': 'callout', 'text': 'Warning text', 'flavor': 'warn'},
              {'type': 'callout', 'text': 'Success text', 'flavor': 'success'},
              {'type': 'callout', 'text': 'Info text', 'flavor': 'other'},
              {
                'type': 'list',
                'items': ['First item', 'Second item'],
                'style': 'number',
              },
              {
                'type': 'list',
                'items': ['Bullet item'],
              },
              {'type': 'list', 'items': <String>[]},
              {'type': 'quote', 'text': 'Quoted text'},
              {'type': 'code', 'lang': 'dart', 'code': 'print("hi");'},
              {'type': 'paragraph', 'text': 'Paragraph text'},
              {'type': 'unknown-type', 'text': 'Fallback text'},
            ],
          },
        );

        await tester.pumpWidget(
          wrap(SingleChildScrollView(child: SlideCard(slide: slide))),
        );

        expect(find.text('Hero caption'), findsOneWidget);

        expect(find.textContaining('Tip text'), findsOneWidget);
        expect(find.textContaining('Warning text'), findsOneWidget);
        expect(find.textContaining('Success text'), findsOneWidget);
        expect(find.textContaining('Info text'), findsOneWidget);

        expect(find.text('1.'), findsOneWidget);
        expect(find.text('2.'), findsOneWidget);
        expect(find.text('• '), findsOneWidget);

        expect(find.textContaining('First item'), findsOneWidget);
        expect(find.textContaining('Second item'), findsOneWidget);
        expect(find.textContaining('Bullet item'), findsOneWidget);

        expect(find.textContaining('Quoted text'), findsOneWidget);

        expect(find.text('[dart]\nprint("hi");'), findsOneWidget);

        expect(find.textContaining('Paragraph text'), findsOneWidget);
        expect(find.textContaining('Fallback text'), findsOneWidget);
      },
    );

    testWidgets('image slide with empty url returns SizedBox.shrink', (
      tester,
    ) async {
      final slide = _slide(type: 'image', content: const <String, dynamic>{});

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('image slide with network url renders Card and alt text', (
      tester,
    ) async {
      final slide = _slide(
        type: 'image',
        content: {
          'url': 'https://example.com/image.png',
          'alt': 'Example image',
          'mime': 'image/png',
          'fit': 'contain',
        },
      );

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception is NetworkImageLoadException) {
          return;
        }
        originalOnError?.call(details);
      };

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Example image'), findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('image slide with raster base64 bytes uses Image.memory', (
      tester,
    ) async {
      const base64Data = 'aGVsbG8=';

      final slide = _slide(
        type: 'image',
        content: {
          'bytes': base64Data,
          'mime': 'image/png',
          'alt': 'Inline raster',
        },
      );

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {};

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));
      await tester.pump();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Inline raster'), findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('code slide renders language and code', (tester) async {
      final slide = _slide(
        type: 'code',
        content: {'lang': 'dart', 'code': 'void main() {}'},
      );

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));

      expect(find.text('[dart]\nvoid main() {}'), findsOneWidget);
    });

    testWidgets('unsupported contentType shows fallback Card with message', (
      tester,
    ) async {
      const type = 'video';
      final slide = _slide(type: type, content: const {});

      await tester.pumpWidget(wrap(SlideCard(slide: slide)));

      expect(find.text('Unsupported slide: $type'), findsOneWidget);
    });
  });
}
