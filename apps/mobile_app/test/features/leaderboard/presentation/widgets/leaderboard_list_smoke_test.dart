import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_list.dart';
import '../../../../helpers/test_wrap.dart';

void main() {
  testWidgets('LeaderboardList renders with empty entries', (tester) async {
    await tester.pumpWidget(wrap(const LeaderboardList(entries: [])));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(LeaderboardList), findsOneWidget);
  });
}
