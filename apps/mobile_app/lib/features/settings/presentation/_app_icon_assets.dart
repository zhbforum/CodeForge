import 'package:mobile_app/features/settings/domain/app_settings.dart';

extension AppIconStyleX on AppIconStyle {
  String get label => switch (this) {
    AppIconStyle.classic => 'Classic',
    AppIconStyle.outline => 'Outline',
    AppIconStyle.gradient => 'Gradient',
  };

  String get previewAsset => switch (this) {
    AppIconStyle.classic => 'assets/icons/logo/classic.jpg',
    AppIconStyle.outline => 'assets/icons/logo/outline.jpg',
    AppIconStyle.gradient => 'assets/icons/logo/gradient.jpg',
  };
}
