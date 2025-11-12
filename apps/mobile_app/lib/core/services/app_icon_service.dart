import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AppIconAlias {
  classic('MainActivityAliasClassic'),
  outline('MainActivityAliasOutline'),
  gradient('MainActivityAliasGradient');

  const AppIconAlias(this.value);
  final String value;
}

class AppIconService {
  static const _channel = MethodChannel('app_icon');

  @visibleForTesting
  static bool? debugIsAndroidOverride;

  static Future<void> switchIcon(AppIconAlias alias) async {
    final isAndroid = debugIsAndroidOverride ?? Platform.isAndroid;
    if (!isAndroid) return;
    await _channel.invokeMethod('switchIcon', {'alias': alias.value});
  }
}
