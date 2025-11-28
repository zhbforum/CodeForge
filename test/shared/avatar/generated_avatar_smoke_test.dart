import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';
import '../../helpers/test_wrap.dart';

void main() {
  testWidgets('GeneratedAvatar renders with a seed', (tester) async {
    await tester.pumpWidget(
      wrap(const GeneratedAvatar(seed: 'alice', size: 40)),
    );
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(GeneratedAvatar), findsOneWidget);
  });
}
