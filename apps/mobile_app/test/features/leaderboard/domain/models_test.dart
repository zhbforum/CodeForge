import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';

void main() {
  group('UserStats.empty', () {
    test('returns zeroed stats with level 1', () {
      final stats = UserStats.empty();

      expect(stats, isA<UserStats>());
      expect(stats.totalExp, 0);
      expect(stats.seasonExp, 0);
      expect(stats.level, 1);
    });
  });
}
