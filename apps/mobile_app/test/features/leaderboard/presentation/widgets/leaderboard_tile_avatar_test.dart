import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_tile.dart'
    as leaderboard;

import '../../../../helpers/test_wrap.dart';

LeaderboardEntry _entryWithAvatar(String avatarUrl) {
  return LeaderboardEntry(
    rank: 1,
    displayName: 'Alice',
    avatarUrl: avatarUrl,
    level: 10,
    leagueName: 'Bronze League',
    seasonExp: 123,
    totalExp: 456,
  );
}

Future<void> _drainExpectedImageErrors(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 10));

    while (true) {
      final Object? error = tester.takeException();
      if (error == null) break;

      final isNetworkImageError = error is NetworkImageLoadException;
      final isInvalidSvgError =
          error is StateError && error.toString().contains('Invalid SVG data');

      if (isNetworkImageError || isInvalidSvgError) {
        continue;
      }

      if (error is Error || error is Exception) {
        // ignore: only_throw_errors
        throw error;
      }

      fail('Unexpected non-Error/Exception thrown: $error');
    }
  }
}

void main() {
  test(
    'buildSvgAvatarForTest uses default SvgPicture.network implementation',
    () {
      leaderboard.svgAvatarBuilderOverride = null;

      final widget = leaderboard.buildSvgAvatarForTest(
        'https://example.com/avatar.svg',
      );

      expect(widget, isA<SvgPicture>());
    },
  );

  test('buildSvgAvatarForTest delegates to override when set', () {
    var called = false;

    leaderboard.svgAvatarBuilderOverride = (url) {
      called = true;
      return SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">
  <circle cx="5" cy="5" r="5" fill="#ff0000" />
</svg>
''');
    };

    leaderboard.buildSvgAvatarForTest('https://example.com/avatar.svg');

    expect(called, isTrue);
  });

  setUpAll(() {
    leaderboard.svgAvatarBuilderOverride = (url) => SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 44 44">
  <rect width="44" height="44" fill="#000000" />
</svg>
''');
  });

  tearDownAll(() {
    leaderboard.svgAvatarBuilderOverride = null;
  });

  group('LeaderboardTile avatar handling', () {
    testWidgets('uses NetworkImage when avatarUrl is non-SVG', (tester) async {
      final entry = _entryWithAvatar('https://example.com/avatar.png');

      await tester.pumpWidget(wrap(leaderboard.LeaderboardTile(entry: entry)));
      await _drainExpectedImageErrors(tester);

      final avatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );

      expect(avatar.foregroundImage, isA<NetworkImage>());
      final image = avatar.foregroundImage! as NetworkImage;
      expect(image.url, 'https://example.com/avatar.png');
    });

    testWidgets('detects SVG via "/svg" and renders SvgPicture', (
      tester,
    ) async {
      final entry = _entryWithAvatar('https://cdn.example.com/svg/avatar123');

      await tester.pumpWidget(wrap(leaderboard.LeaderboardTile(entry: entry)));
      await _drainExpectedImageErrors(tester);

      final avatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(avatar.foregroundImage, isNull);

      final clipOvalFinder = find.descendant(
        of: find.byType(leaderboard.LeaderboardTile),
        matching: find.byType(ClipOval),
      );
      expect(clipOvalFinder, findsOneWidget);

      final svgFinder = find.descendant(
        of: clipOvalFinder,
        matching: find.byType(SvgPicture),
      );
      expect(svgFinder, findsOneWidget);
    });

    testWidgets('detects SVG via "format=svg" and renders SvgPicture', (
      tester,
    ) async {
      final entry = _entryWithAvatar(
        'https://images.example.com/avatar.png?size=64&format=svg',
      );

      await tester.pumpWidget(wrap(leaderboard.LeaderboardTile(entry: entry)));
      await _drainExpectedImageErrors(tester);

      final avatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(avatar.foregroundImage, isNull);

      final clipOvalFinder = find.descendant(
        of: find.byType(leaderboard.LeaderboardTile),
        matching: find.byType(ClipOval),
      );
      expect(clipOvalFinder, findsOneWidget);

      final svgFinder = find.descendant(
        of: clipOvalFinder,
        matching: find.byType(SvgPicture),
      );
      expect(svgFinder, findsOneWidget);
    });
  });
}
