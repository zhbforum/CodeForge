import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthClient extends Mock implements AuthClient {}

class _MockErrorHandler extends Mock implements ErrorHandler {}

void main() {
  late _MockAuthClient auth;
  late _MockErrorHandler errorHandler;
  late AuthService service;

  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    auth = _MockAuthClient();
    errorHandler = _MockErrorHandler();
    service = AuthService(auth: auth, errorHandler: errorHandler);
  });

  group('AuthService getters', () {
    test('currentSession delegates to _auth.currentSession', () {
      when(() => auth.currentSession).thenReturn(null);

      final result = service.currentSession;

      expect(result, isNull);
      verify(() => auth.currentSession).called(1);
    });

    test('currentUser delegates to _auth.currentUser', () {
      when(() => auth.currentUser).thenReturn(null);

      final result = service.currentUser;

      expect(result, isNull);
      verify(() => auth.currentUser).called(1);
    });
  });

  group('AuthService.signInWithPassword', () {
    test('calls auth and ErrorHandler on AuthException', () async {
      const exception = AuthException('boom');

      when(
        () => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(exception);

      expect(
        () => service.signInWithPassword('test@example.com', 'secret'),
        throwsA(isA<AuthException>()),
      );

      verify(
        () => auth.signInWithPassword(
          email: 'test@example.com',
          password: 'secret',
        ),
      ).called(1);
      verify(() => errorHandler.handle(exception, any())).called(1);
    });
  });

  group('AuthService.signUpWithPassword', () {
    test('calls auth.signUp and ErrorHandler on AuthException', () async {
      const exception = AuthException('signup failed');

      when(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenThrow(exception);

      expect(
        () => service.signUpWithPassword('user@example.com', 'pwd'),
        throwsA(isA<AuthException>()),
      );

      verify(
        () => auth.signUp(
          email: 'user@example.com',
          password: 'pwd',
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).called(1);
      verify(() => errorHandler.handle(exception, any())).called(1);
    });
  });

  group('AuthService.signInWithOAuth', () {
    test(
      'calls auth.signInWithOAuth and ErrorHandler on AuthException',
      () async {
        const exception = AuthException('oauth failed');

        when(
          () => auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: any(named: 'redirectTo'),
          ),
        ).thenThrow(exception);

        expect(
          () => service.signInWithOAuth(OAuthProvider.google),
          throwsA(isA<AuthException>()),
        );

        verify(
          () => auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: any(named: 'redirectTo'),
          ),
        ).called(1);
        verify(() => errorHandler.handle(exception, any())).called(1);
      },
    );
  });

  group('AuthService.signOut', () {
    test('calls auth.signOut and ErrorHandler on AuthException', () async {
      const exception = AuthException('signout failed');

      when(() => auth.signOut()).thenThrow(exception);

      expect(() => service.signOut(), throwsA(isA<AuthException>()));

      verify(() => auth.signOut()).called(1);
      verify(() => errorHandler.handle(exception, any())).called(1);
    });
  });

  group('AuthService.sendMagicLink', () {
    test(
      'calls auth.signInWithOtp and ErrorHandler on AuthException',
      () async {
        const exception = AuthException('magic link failed');

        when(
          () => auth.signInWithOtp(
            email: any(named: 'email'),
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).thenThrow(exception);

        expect(
          () => service.sendMagicLink('user@example.com'),
          throwsA(isA<AuthException>()),
        );

        verify(
          () => auth.signInWithOtp(
            email: 'user@example.com',
            emailRedirectTo: any(named: 'emailRedirectTo'),
          ),
        ).called(1);
        verify(() => errorHandler.handle(exception, any())).called(1);
      },
    );
  });
}
