import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/pages/signup_page.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream<AuthState>.empty();

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return AuthResponse();
  }

  @override
  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    return AuthResponse();
  }

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {}

  @override
  Future<void> signOut() async {}
}

class _SessionAuthRepository implements AuthRepository {
  _SessionAuthRepository()
    : _user = const User(
        id: 'user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        email: 'user@example.com',
        createdAt: '2024-01-01T00:00:00Z',
        role: 'authenticated',
      ),
      _session = Session(
        accessToken: 'access-token',
        expiresIn: 3600,
        refreshToken: 'refresh-token',
        tokenType: 'bearer',
        user: const User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          email: 'user@example.com',
          createdAt: '2024-01-01T00:00:00Z',
          role: 'authenticated',
        ),
      );

  final User _user;
  final Session _session;

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _user;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream<AuthState>.empty();

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {}

  @override
  Future<void> signOut() async {}
}

class _ThrowingAuthRepository implements AuthRepository {
  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream<AuthState>.empty();

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return AuthResponse();
  }

  @override
  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    throw Exception('boom');
  }

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {}

  @override
  Future<void> signOut() async {}
}

ProviderContainer _createContainer({
  Stream<AuthState>? authStream,
  AuthRepository? authRepository,
}) {
  return ProviderContainer(
    overrides: [
      authStateStreamProvider.overrideWith(
        (ref) => authStream ?? const Stream<AuthState>.empty(),
      ),
      authRepositoryProvider.overrideWith(
        (ref) => authRepository ?? _FakeAuthRepository(),
      ),
    ],
  );
}

Widget _buildApp(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/auth/signup',
    routes: [
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LoginPage'))),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('ProfilePage'))),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _fillValidForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(3));

  await tester.enterText(fields.at(0), 'test@example.com');
  await tester.enterText(fields.at(1), 'strong-password');
  await tester.enterText(fields.at(2), 'strong-password');
}

void main() {
  group('SignUpPage', () {
    testWidgets('renders core UI elements', (tester) async {
      final container = _createContainer();

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(
        find.text("Let's get you started on your coding journey."),
        findsOneWidget,
      );
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('By signing up, you agree to our'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('submit with invalid form does not crash (early return)', (
      tester,
    ) async {
      final container = _createContainer();

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      final signUpButton = find.widgetWithText(FilledButton, 'Sign Up');
      expect(signUpButton, findsOneWidget);

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets(
      'back button navigates to /profile when cannot pop (canPop == false)',
      (tester) async {
        final container = _createContainer();

        await tester.pumpWidget(_buildApp(container));
        await tester.pumpAndSettle();

        expect(find.text('Create your account'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
        await tester.pumpAndSettle();

        expect(find.text('ProfilePage'), findsOneWidget);
      },
    );

    testWidgets('Sign In button navigates to /auth/login', (tester) async {
      final container = _createContainer();

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      final signInButton = find.widgetWithText(TextButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
    });

    testWidgets('navigates to returnTo when authState emits signedIn event', (
      tester,
    ) async {
      final authStateController = StreamController<AuthState>();
      final container = _createContainer(
        authStream: authStateController.stream,
      );

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Create your account'), findsOneWidget);

      authStateController.add(const AuthState(AuthChangeEvent.signedIn, null));
      await tester.pumpAndSettle();

      expect(find.text('ProfilePage'), findsOneWidget);

      await authStateController.close();
    });

    testWidgets('shows snackbar when authViewModel emits AsyncError', (
      tester,
    ) async {
      final container = _createContainer();

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      container.read(authViewModelProvider.notifier).state = const AsyncError(
        'failure',
        StackTrace.empty,
      );

      await tester.pump();

      expect(find.text('Auth error: failure'), findsOneWidget);
    });

    testWidgets('tapping Terms of Service does not crash', (tester) async {
      final container = _createContainer();

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      final terms = find.text('Terms of Service');
      expect(terms, findsOneWidget);

      await tester.tap(terms);
      await tester.pump();

      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('submit shows confirm-email snackbar when session is null', (
      tester,
    ) async {
      final container = _createContainer(authRepository: _FakeAuthRepository());

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Check and confirm your e-mail.'), findsOneWidget);
    });

    testWidgets('submit navigates to returnTo when session is not null', (
      tester,
    ) async {
      final container = _createContainer(
        authRepository: _SessionAuthRepository(),
      );

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('ProfilePage'), findsOneWidget);
    });

    testWidgets('submit shows error snackbar when signUpWithPassword throws', (
      tester,
    ) async {
      final container = _createContainer(
        authRepository: _ThrowingAuthRepository(),
      );

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      if (kDebugMode) {}

      expect(find.textContaining('Exception: boom'), findsWidgets);
    });
  });
}
