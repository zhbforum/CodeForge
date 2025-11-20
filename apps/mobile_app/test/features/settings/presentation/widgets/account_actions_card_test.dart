import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/settings/presentation/widgets/account_actions_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeAuthViewModel extends AuthViewModel {
  _FakeAuthViewModel() : super(_MockAuthRepository());

  @override
  Future<void> signOut() async {}
}

class _ThrowingAuthViewModel extends AuthViewModel {
  _ThrowingAuthViewModel() : super(_MockAuthRepository());

  @override
  Future<void> signOut() async {
    throw Exception('boom');
  }
}

AuthState _authStateWithSession() {
  final session = Session.fromJson({
    'access_token': 'dummy-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'refresh_token': 'dummy-rt',
    'user': {
      'id': 'user-id',
      'aud': 'authenticated',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': '2025-01-01T00:00:00Z',
    },
  });

  return AuthState(AuthChangeEvent.signedIn, session);
}

Widget _buildTestApp({required List<Override> overrides}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: AccountActionsCard()),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const Scaffold(body: Text('Welcome')),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('AccountActionsCard', () {
    testWidgets('renders nothing when there is no session', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => const Stream<AuthState>.empty(),
            ),
            authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsNothing);
      expect(find.text('Delete account'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders sign-out and delete actions when session exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => Stream<AuthState>.value(_authStateWithSession()),
            ),
            authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('delete account flow: cancel closes dialog', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => Stream<AuthState>.value(_authStateWithSession()),
            ),
            authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete account?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('delete account flow: confirm shows snackbar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => Stream<AuthState>.value(_authStateWithSession()),
            ),
            authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Deletion is not implemented on client side.'),
        findsOneWidget,
      );
    });

    testWidgets('sign out tap does not crash', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => Stream<AuthState>.value(_authStateWithSession()),
            ),
            authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AccountActionsCard), findsOneWidget);
    });

    testWidgets('sign out tap shows error snackbar when signOut throws', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => Stream<AuthState>.value(_authStateWithSession()),
            ),
            authViewModelProvider.overrideWith(
              (ref) => _ThrowingAuthViewModel(),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Sign-out error:'), findsOneWidget);
    });
  });
}
