import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorHandler.message', () {
    final handler = ErrorHandler();

    test('returns auth message for AuthException', () {
      const error = AuthException('Invalid credentials');
      expect(
        handler.message(error),
        'Authentication error: Invalid credentials',
      );
    });

    test('returns database message for PostgrestException', () {
      const error = PostgrestException(
        message: 'Row not found',
        code: 'PGRST116',
      );
      expect(handler.message(error), 'Database error: Row not found');
    });

    test('returns network message for SocketException', () {
      const error = SocketException('No internet');
      expect(handler.message(error), 'Check your internet connection');
    });

    test('returns timeout message for TimeoutException', () {
      final error = TimeoutException('Too slow');
      expect(handler.message(error), 'Server is not responding');
    });

    test('returns fallback message for unknown error', () {
      final error = Exception('Something unexpected');
      expect(handler.message(error), 'Unknown error. Please try again later');
    });
  });

  group('ErrorHandler.handle', () {
    final handler = ErrorHandler();
    final stackTrace = StackTrace.current;

    test('handles AuthException', () {
      const error = AuthException('Auth failed');
      handler.handle(error, stackTrace);
    });

    test('handles PostgrestException', () {
      const error = PostgrestException(message: 'DB failed', code: 'PGRST000');
      handler.handle(error, stackTrace);
    });

    test('handles SocketException', () {
      const error = SocketException('No internet');
      handler.handle(error, stackTrace);
    });

    test('handles TimeoutException', () {
      final error = TimeoutException('Timeout');
      handler.handle(error, stackTrace);
    });

    test('handles unknown error type', () {
      final error = StateError('Weird state');
      handler.handle(error, stackTrace);
    });
  });
}
