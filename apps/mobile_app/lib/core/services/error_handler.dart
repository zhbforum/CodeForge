import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {

  void handle(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[ErrorHandler] ${error.runtimeType}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    switch (error.runtimeType) {
      case PostgrestException:
        final e = error as PostgrestException;
        _log('Postgrest error', e.message, e.code);
      case AuthException:
        final e = error as AuthException;
        _log('Auth error', e.message, e.statusCode?.toString());
      case SocketException:
        _log('Network error', 'Without internet connection');
      case TimeoutException:
        _log('Timeout error', 'Request timeout exceeded');
      default:
        _log('Unknown error', error.toString());
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
      // ignore: lines_longer_than_80_chars
      debugPrint('[ErrorHandler] $type ${code != null ? '($code)' : ''}: $message');
    }
  }
}
