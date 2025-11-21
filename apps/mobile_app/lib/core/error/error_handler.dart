import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/error/error_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final errorNotifier = ref.read(appErrorProvider.notifier);
  return ErrorHandler(showUiErrorCallback: errorNotifier.show);
});

class ErrorHandler {
  ErrorHandler({required this.showUiErrorCallback});

  final void Function(String message) showUiErrorCallback;

  void handle(Object error, StackTrace stackTrace, {bool showUiError = true}) {
    if (error is StateError && error.message == 'User not logged in') {
      debugPrint('[ErrorHandler] User not logged in');
      return;
    }

    if (error is PostgrestException) {
      _log('Postgrest error', error.message, error.code);
    } else if (error is AuthException) {
      _log('Auth error', error.message, error.statusCode?.toString());
    } else if (error is SocketException) {
      _log('Network error', 'Without internet connection');
    } else if (error is TimeoutException) {
      _log('Timeout error', 'Request timeout exceeded');
    } else {
      _log('Unknown error', error.toString());
    }

    if (showUiError) {
      showUiErrorCallback(message(error));
    }
  }

  String message(Object error) {
    if (error is AuthException) {
      return 'Authentication error: ${error.message}';
    } else if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    } else if (error is SocketException) {
      return 'Check your internet connection';
    } else if (error is TimeoutException) {
      return 'Server is not responding';
    } else {
      return 'Unknown error. Please try again later';
    }
  }

  void _log(String type, String? message, [String? code]) {
    if (kDebugMode) {
      debugPrint(
        '[ErrorHandler] $type ${code != null ? '($code)' : ''}: $message',
      );
    }
  }
}
