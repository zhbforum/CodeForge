import 'dart:io' show Platform;
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

  static Future<void> switchIcon(AppIconAlias alias) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('switchIcon', {'alias': alias.value});
  }
}
