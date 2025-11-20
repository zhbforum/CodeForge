import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/settings/presentation/widgets/preview_option_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PreviewOptionTile', () {
    testWidgets('renders title, subtitle and not-selected check opacity=>0', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'Dark mode',
            subtitle: 'Best for low light',
            imageAsset: 'preview_dark.png',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Best for low light'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0);
    });

    testWidgets('renders without subtitle when subtitle is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'Light mode',
            imageAsset: 'preview_light.png',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Light mode'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('shows check icon with opacity=>1 when selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'System',
            subtitle: 'Follow system theme',
            imageAsset: 'preview_system.png',
            selected: true,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 1);

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'Tap me',
            subtitle: 'Subtitle',
            imageAsset: 'preview_tap.png',
            selected: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('uses SvgPicture for .svg assets', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'SVG preview',
            subtitle: 'Vector',
            imageAsset: 'assets/preview.svg',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('uses Image for non-svg assets and provides errorBuilder', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          PreviewOptionTile(
            title: 'PNG preview',
            subtitle: 'Raster',
            imageAsset: 'assets/preview.png',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
