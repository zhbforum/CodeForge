import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/settings/domain/app_settings.dart';
import 'package:mobile_app/features/settings/presentation/_app_icon_assets.dart';

void main() {
  group('AppIconStyleX (label/previewAsset)', () {
    test('label maps correctly for all styles', () {
      expect(AppIconStyle.classic.label, 'Classic');
      expect(AppIconStyle.outline.label, 'Outline');
      expect(AppIconStyle.gradient.label, 'Gradient');
    });

    test('previewAsset maps to correct asset paths', () {
      expect(
        AppIconStyle.classic.previewAsset,
        'assets/icons/logo/classic.jpg',
      );
      expect(
        AppIconStyle.outline.previewAsset,
        'assets/icons/logo/outline.jpg',
      );
      expect(
        AppIconStyle.gradient.previewAsset,
        'assets/icons/logo/gradient.jpg',
      );
    });
  });
}
