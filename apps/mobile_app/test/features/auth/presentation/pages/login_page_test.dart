import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
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

class _FakeAuthViewModel extends AuthViewModel {
  _FakeAuthViewModel() : super(_FakeAuthRepository());

  String? lastEmail;
  String? lastPassword;
  OAuthProvider? lastProvider;

  @override
  Future<void> signInWithPassword(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    state = const AsyncData(null);
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    lastProvider = provider;
    state = const AsyncData(null);
  }
}

class _ErrorLaterAuthViewModel extends AuthViewModel {
  _ErrorLaterAuthViewModel() : super(_FakeAuthRepository());

  void fail() {
    state = const AsyncError(AuthException('failure'), StackTrace.empty);
  }
}

Session _buildFakeSession() {
  final userJson = <String, dynamic>{
    'id': 'test-user-id',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'aud': 'authenticated',
    'created_at': '2025-01-01T00:00:00Z',
  };

  final user = User.fromJson(userJson)!;

  return Session(
    accessToken: 'test-access-token',
    expiresIn: 3600,
    refreshToken: 'test-refresh-token',
    tokenType: 'bearer',
    user: user,
  );
}

TextSpan? _findTextSpanByText(InlineSpan span, String target) {
  if (span is TextSpan) {
    if (span.text == target) return span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      final found = _findTextSpanByText(child, target);
      if (found != null) return found;
    }
  }
  return null;
}

Widget _buildApp({
  required GoRouter router,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/auth/login',
      routes: [
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Profile page'))),
        ),
        GoRoute(
          path: '/auth/signup',
          builder: (context, state) {
            final from = state.uri.queryParameters['from'];
            return Scaffold(
              body: Center(child: Text('Sign Up page (from: $from)')),
            );
          },
        ),
      ],
    );
  });

  testWidgets('LoginPage _submit calls view model and navigates to returnTo', (
    tester,
  ) async {
    late _FakeAuthViewModel fakeVm;

    final overrides = <Override>[
      authStateStreamProvider.overrideWith(
        (ref) => const Stream<AuthState>.empty(),
      ),
      authViewModelProvider.overrideWith(
        (ref) => fakeVm = _FakeAuthViewModel(),
      ),
    ];

    await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passwordField, 'Password123!');

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(fakeVm.lastEmail, 'user@example.com');
    expect(fakeVm.lastPassword, 'Password123!');

    expect(find.text('Profile page'), findsOneWidget);
  });

  testWidgets(
    'LoginPage OAuth buttons call signInWithOAuth with correct providers',
    (tester) async {
      late _FakeAuthViewModel fakeVm;

      final overrides = <Override>[
        authStateStreamProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        authViewModelProvider.overrideWith(
          (ref) => fakeVm = _FakeAuthViewModel(),
        ),
      ];

      await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
      await tester.pumpAndSettle();

      final googleIcon = find.byWidgetPredicate(
        (w) => w is FaIcon && w.icon == FontAwesomeIcons.google,
      );
      final githubIcon = find.byWidgetPredicate(
        (w) => w is FaIcon && w.icon == FontAwesomeIcons.github,
      );
      final facebookIcon = find.byWidgetPredicate(
        (w) => w is FaIcon && w.icon == FontAwesomeIcons.facebook,
      );

      await tester.tap(googleIcon);
      await tester.pump();
      expect(fakeVm.lastProvider, OAuthProvider.google);

      await tester.tap(githubIcon);
      await tester.pump();
      expect(fakeVm.lastProvider, OAuthProvider.github);

      await tester.tap(facebookIcon);
      await tester.pump();
      expect(fakeVm.lastProvider, OAuthProvider.facebook);
    },
  );

  testWidgets(
    'LoginPage does not crash when Auth AsyncError is emitted from view model listener',
    (tester) async {
      late _ErrorLaterAuthViewModel vm;

      final overrides = <Override>[
        authStateStreamProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        authViewModelProvider.overrideWith(
          (ref) => vm = _ErrorLaterAuthViewModel(),
        ),
      ];

      await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
      await tester.pump();

      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);

      vm.fail();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
      expect(find.text('Authentication error: failure'), findsNothing);
    },
  );

  testWidgets('LoginPage redirects when authState emits signedIn event', (
    tester,
  ) async {
    final controller = StreamController<AuthState>();

    final overrides = <Override>[
      authStateStreamProvider.overrideWith((ref) => controller.stream),
      authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
    ];

    await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
    await tester.pump();

    controller.add(const AuthState(AuthChangeEvent.signedIn, null));
    await tester.pumpAndSettle();

    expect(find.text('Profile page'), findsOneWidget);

    await controller.close();
  });

  testWidgets(
    'LoginPage redirects from build authState already has a non-null session',
    (tester) async {
      final fakeSession = _buildFakeSession();

      final overrides = <Override>[
        authStateStreamProvider.overrideWith(
          (ref) => Stream<AuthState>.value(
            AuthState(AuthChangeEvent.signedIn, fakeSession),
          ),
        ),
        authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
      ];

      await tester.pumpWidget(_buildApp(router: router, overrides: overrides));

      await tester.pump();
      await tester.pump();

      expect(find.text('Profile page'), findsOneWidget);
    },
  );

  testWidgets('LoginPage close button navigates to /profile when cannot pop', (
    tester,
  ) async {
    final overrides = <Override>[
      authStateStreamProvider.overrideWith(
        (ref) => const Stream<AuthState>.empty(),
      ),
      authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
    ];

    await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Profile page'), findsOneWidget);
  });

  testWidgets(
    'LoginPage "Sign Up" link navigates to /auth/signup with from=query',
    (tester) async {
      final overrides = <Override>[
        authStateStreamProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        authViewModelProvider.overrideWith((ref) => _FakeAuthViewModel()),
      ];

      await tester.pumpWidget(_buildApp(router: router, overrides: overrides));
      await tester.pumpAndSettle();

      final signUpRichTextFinder = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Sign Up'),
      );

      expect(signUpRichTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(signUpRichTextFinder);
      final rootSpan = richText.text as TextSpan;

      final signUpSpan = _findTextSpanByText(rootSpan, 'Sign Up');
      expect(signUpSpan, isNotNull);

      final recognizer = signUpSpan!.recognizer as TapGestureRecognizer?;
      recognizer?.onTap?.call();

      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sign Up page (from: /profile)'),
        findsOneWidget,
      );
    },
  );
}
