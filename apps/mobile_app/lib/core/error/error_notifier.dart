import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/app_error.dart';

final appErrorProvider = StateNotifierProvider<AppErrorNotifier, AppError?>((
  ref,
) {
  return AppErrorNotifier();
});

class AppErrorNotifier extends StateNotifier<AppError?> {
  AppErrorNotifier() : super(null);

  Timer? _timer;

  void show(String message) {
    state = AppError(message);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      state = null;
    });
  }

  void clear() {
    state = null;
    _timer?.cancel();
    _timer = null;
  }
}
