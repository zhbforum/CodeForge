import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppConfig {
  const AppConfig({this.funAnimationsEnabled = true});
  final bool funAnimationsEnabled;
}

final appConfigProvider = Provider<AppConfig>((_) => const AppConfig());

final reduceMotionProvider = Provider<bool>((ref) {
  final cfg = ref.watch(appConfigProvider);
  final platformReduce = WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;
  return platformReduce || !cfg.funAnimationsEnabled;
});
