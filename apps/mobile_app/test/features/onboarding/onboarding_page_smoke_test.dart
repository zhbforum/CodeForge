import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import '../../helpers/test_wrap.dart';

void main() {
  testWidgets('OnboardingPage builds', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingPage()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}
