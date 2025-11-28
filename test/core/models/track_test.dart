import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/track.dart';

// We intentionally avoid `const` here so the constructor runs at runtime
// and is visible in coverage. In a small test like this, the performance
// impact is negligible.
// ignore_for_file: prefer_const_constructors

void main() {
  group('Track model', () {
    test('creates instance with all fields', () {
      final track = Track(
        id: TrackId.fullstack,
        title: 'Fullstack track',
        subtitle: 'From zero to hero',
        progress: 0.75,
        locked: true,
        iconName: 'react',
      );

      expect(track.id, TrackId.fullstack);
      expect(track.title, 'Fullstack track');
      expect(track.subtitle, 'From zero to hero');
      expect(track.progress, 0.75);
      expect(track.locked, isTrue);
      expect(track.iconName, 'react');
    });

    test('uses default values for optional fields', () {
      final track = Track(
        id: TrackId.python,
        title: 'Python track',
        subtitle: 'Intro to Python',
        progress: 0,
      );

      expect(track.locked, isFalse);
      expect(track.iconName, isNull);
    });
  });
}
