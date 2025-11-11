import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/core/ui/tech_icon.dart';

void main() {
  test('iconsForTrackId mapping returns expected tech lists', () {
    expect(
      iconsForTrackId(TrackId.fullstack),
      equals(const [Tech.html, Tech.css, Tech.js, Tech.react]),
    );
    expect(
      iconsForTrackId(TrackId.backend),
      equals(const [Tech.node, Tech.db, Tech.lock]),
    );
    expect(iconsForTrackId(TrackId.python), equals(const [Tech.python]));
    expect(iconsForTrackId(TrackId.typescript), equals(const [Tech.ts]));
  });
}
