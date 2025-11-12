import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/app_icon_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppIconAlias values are mapped correctly', () {
    expect(AppIconAlias.classic.value, 'MainActivityAliasClassic');
    expect(AppIconAlias.outline.value, 'MainActivityAliasOutline');
    expect(AppIconAlias.gradient.value, 'MainActivityAliasGradient');
  });

  test(
    'switchIcon is no-op on non-Android (no channel invocation, no throw)',
    () async {
      const channel = MethodChannel('app_icon');
      var invoked = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
            invoked = true;
            return null;
          });

      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        AppIconService.debugIsAndroidOverride = null;
      });

      await AppIconService.switchIcon(AppIconAlias.classic);
      expect(invoked, isFalse);
    },
  );

  test('switchIcon invokes channel on Android with correct args', () async {
    const channel = MethodChannel('app_icon');
    MethodCall? captured;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          captured = call;
          return null;
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      AppIconService.debugIsAndroidOverride = null;
    });

    AppIconService.debugIsAndroidOverride = true;

    await AppIconService.switchIcon(AppIconAlias.outline);

    expect(captured?.method, 'switchIcon');
    expect(captured?.arguments, {'alias': 'MainActivityAliasOutline'});
  });
}
