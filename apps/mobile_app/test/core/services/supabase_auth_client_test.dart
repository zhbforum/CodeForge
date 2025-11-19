import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockGoTrueClient inner;
  late SupabaseAuthClient client;

  setUp(() {
    inner = _MockGoTrueClient();
    client = SupabaseAuthClient(inner);
  });

  group('SupabaseAuthClient getters', () {
    test('currentSession delegates to inner.currentSession', () {
      when(() => inner.currentSession).thenReturn(null);

      final result = client.currentSession;

      expect(result, isNull);
      verify(() => inner.currentSession).called(1);
    });

    test('currentUser delegates to inner.currentUser', () {
      when(() => inner.currentUser).thenReturn(null);

      final result = client.currentUser;

      expect(result, isNull);
      verify(() => inner.currentUser).called(1);
    });
  });

  group('SupabaseAuthClient.signInWithPassword', () {
    test('forwards parameters and returns inner result', () async {
      final response = AuthResponse();

      when(
        () => inner.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.signInWithPassword(
        email: 'user@example.com',
        password: 'pwd',
      );

      expect(result, same(response));
      verify(
        () => inner.signInWithPassword(
          email: 'user@example.com',
          password: 'pwd',
        ),
      ).called(1);
    });
  });

  group('SupabaseAuthClient.signUp', () {
    test('forwards parameters and returns inner result', () async {
      final response = AuthResponse();

      when(
        () => inner.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async => response);

      final result = await client.signUp(
        email: 'user@example.com',
        password: 'pwd',
        emailRedirectTo: 'codeforge://auth-callback',
      );

      expect(result, same(response));
      verify(
        () => inner.signUp(
          email: 'user@example.com',
          password: 'pwd',
          emailRedirectTo: 'codeforge://auth-callback',
        ),
      ).called(1);
    });
  });

  group('SupabaseAuthClient.signOut', () {
    test('forwards call to inner.signOut', () async {
      when(() => inner.signOut()).thenAnswer((_) async {});

      await client.signOut();

      verify(() => inner.signOut()).called(1);
    });
  });

  group('SupabaseAuthClient.signInWithOtp', () {
    test('forwards parameters to inner.signInWithOtp', () async {
      when(
        () => inner.signInWithOtp(
          email: any(named: 'email'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async {});

      await client.signInWithOtp(
        email: 'user@example.com',
        emailRedirectTo: 'codeforge://auth-callback',
      );

      verify(
        () => inner.signInWithOtp(
          email: 'user@example.com',
          emailRedirectTo: 'codeforge://auth-callback',
        ),
      ).called(1);
    });
  });

  group('SupabaseAuthClient.signInWithOAuth', () {
    test(
      'skip:signInWithOAuth is implemented as an extension in supabase_flutter '
      'internally uses getOAuthSignInUrl + platform auth flow, which is not '
      'reliably mockable with mocktail in a pure unit test',
      () {},
      skip: true,
    );
  });
}
