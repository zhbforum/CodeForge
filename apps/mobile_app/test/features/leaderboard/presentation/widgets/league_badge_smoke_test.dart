import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/league_badge.dart';
import '../../../../helpers/test_wrap.dart';

void main() {
  testWidgets('LeagueBadge renders with given league name', (tester) async {
    await tester.pumpWidget(wrap(const LeagueBadge('Bronze')));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(LeagueBadge), findsOneWidget);
    expect(find.text('Bronze'), findsOneWidget);
  });
}
