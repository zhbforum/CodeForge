import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/ui/tech_icon.dart';

import '../../helpers/test_wrap.dart';

void main() {
  testWidgets('TechIconsRow renders one SvgPicture per item with given size', (
    tester,
  ) async {
    const size = 20.0;
    await tester.pumpWidget(
      wrap(
        const TechIconsRow(
          items: [Tech.html, Tech.css, Tech.js],
          size: size,
          spacing: 4,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsNWidgets(3));

    final pics = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
    for (final p in pics) {
      expect(p.width, size);
      expect(p.height, size);
    }
  });
}
