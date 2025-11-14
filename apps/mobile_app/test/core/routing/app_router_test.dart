import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/core/routing/app_router.dart';
import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/signup_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/catalog/presentation/pages/learn_page.dart';
import 'package:mobile_app/features/catalog/presentation/pages/lesson_page.dart';
import 'package:mobile_app/features/catalog/presentation/pages/track_detail_page.dart';
import 'package:mobile_app/features/catalog/presentation/providers/module_providers.dart';
import 'package:mobile_app/features/leaderboard/leaderboard_page.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late GoRouter _router;

final Session? _fakeSession = Session.fromJson({
  'access_token': 'test-access-token',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'test-refresh-token',
  'user': {
    'id': '00000000-0000-0000-0000-000000000000',
    'aud': 'authenticated',
    'email': 'test@example.com',
    'role': 'authenticated',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'created_at': '2021-01-01T00:00:00Z',
    'updated_at': '2021-01-01T00:00:00Z',
  },
});

Future<void> _pumpRouterApp(
  WidgetTester tester, {
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWithValue(const AsyncData<Session?>(null)),
        ...extraOverrides,
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(appRouterProvider);
          _router = router;
          return MaterialApp.router(routerConfig: router);
        },
      ),
    ),
  );

  await tester.pump();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://test-project.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  group('AppRouter auth routes', () {
    testWidgets('LoginPage uses "from" query parameter when provided', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/auth/login?from=/leaderboard');
      await tester.pumpAndSettle();

      final login = tester.widget<LoginPage>(find.byType(LoginPage));
      expect(login.returnTo, '/leaderboard');
    });

    testWidgets('LoginPage falls back to /profile when "from" is missing', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/auth/login');
      await tester.pumpAndSettle();

      final login = tester.widget<LoginPage>(find.byType(LoginPage));
      expect(login.returnTo, '/profile');
    });

    testWidgets(
      'LoginPage ignores unsafe "from" pointing to /auth/* and falls back to /profile',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/auth/login?from=/auth/signup');
        await tester.pumpAndSettle();

        final login = tester.widget<LoginPage>(find.byType(LoginPage));
        expect(login.returnTo, '/profile');
      },
    );

    testWidgets('SignUpPage uses "from" query parameter when provided', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/auth/signup?from=/home');
      await tester.pumpAndSettle();

      final signUp = tester.widget<SignUpPage>(find.byType(SignUpPage));
      expect(signUp.returnTo, '/home');
    });

    testWidgets('SignUpPage falls back to /profile when "from" is missing', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/auth/signup');
      await tester.pumpAndSettle();

      final signUp = tester.widget<SignUpPage>(find.byType(SignUpPage));
      expect(signUp.returnTo, '/profile');
    });

    testWidgets(
      'SignUpPage ignores unsafe "from" = /profile/welcome and falls back to /profile',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/auth/signup?from=/profile/welcome');
        await tester.pumpAndSettle();

        final signUp = tester.widget<SignUpPage>(find.byType(SignUpPage));
        expect(signUp.returnTo, '/profile');
      },
    );

    testWidgets(
      'Authenticated user hitting /auth/login with from is redirected to sanitized target',
      (tester) async {
        await _pumpRouterApp(
          tester,
          extraOverrides: [
            authSessionProvider.overrideWithValue(
              AsyncData<Session?>(_fakeSession),
            ),
          ],
        );

        _router.go('/auth/login?from=/leaderboard');
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsNothing);
        expect(find.byType(LeaderboardPage), findsOneWidget);
      },
    );
  });

  group('AppRouter welcome & protected profile redirect', () {
    testWidgets(
      'Unauthenticated user going to /profile is redirected to /profile/welcome with "from" param',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/profile');
        await tester.pumpAndSettle();

        final welcomeFinder = find.byType(WelcomePage);
        expect(welcomeFinder, findsOneWidget);

        final welcome = tester.widget<WelcomePage>(welcomeFinder);
        expect(welcome.returnTo, '/profile');
      },
    );

    testWidgets('WelcomePage picks up "from" query parameter when present', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/profile/welcome?from=/leaderboard');
      await tester.pumpAndSettle();

      final welcome = tester.widget<WelcomePage>(find.byType(WelcomePage));
      expect(welcome.returnTo, '/leaderboard');
    });
  });

  group('AppRouter shell branches basic smoke', () {
    testWidgets('Home branch renders LearnPage on /home', (tester) async {
      await _pumpRouterApp(tester);

      _router.go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(LearnPage), findsOneWidget);
    });

    testWidgets('Leaderboard branch renders LeaderboardPage on /leaderboard', (
      tester,
    ) async {
      await _pumpRouterApp(tester);

      _router.go('/leaderboard');
      await tester.pumpAndSettle();

      expect(find.byType(LeaderboardPage), findsOneWidget);
    });

    testWidgets(
      'Profile branch renders ProfilePage for authenticated user on /profile',
      (tester) async {
        await _pumpRouterApp(
          tester,
          extraOverrides: [
            authSessionProvider.overrideWithValue(
              AsyncData<Session?>(_fakeSession),
            ),
          ],
        );

        _router.go('/profile');
        await tester.pumpAndSettle();

        expect(find.byType(ProfilePage), findsOneWidget);
      },
    );
  });

  group('AppRouter course / module / lesson routes', () {
    testWidgets(
      'Visiting bare /home/course/:courseId builds auto-redirect helper (loading/error branch)',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/home/course/test-course');

        await tester.pump();
        await tester.pump();
      },
    );

    testWidgets(
      'Module route /home/course/:courseId/module/:moduleId renders TrackDetailPage',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/home/course/course-1/module/module-1');
        await tester.pumpAndSettle();

        expect(find.byType(TrackDetailPage), findsOneWidget);
      },
    );

    testWidgets(
      'Lesson route /home/course/:courseId/module/:moduleId/lesson/:lessonId renders LessonPage',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/home/course/course-1/module/module-1/lesson/lesson-1');
        await tester.pumpAndSettle();

        expect(find.byType(LessonPage), findsOneWidget);
      },
    );
  });

  group('_CourseAutoRedirect data branch', () {
    testWidgets(
      'Bare course route shows "No modules yet" when returns empty list',
      (tester) async {
        const courseId = 'course-empty';

        await _pumpRouterApp(
          tester,
          extraOverrides: [
            courseModulesProvider.overrideWith((ref, id) async {
              expect(id, courseId);
              return <CourseModule>[];
            }),
          ],
        );

        _router.go('/home/course/$courseId');

        await tester.pump();
        await tester.pump();

        expect(find.text('No modules yet'), findsOneWidget);
      },
    );

    testWidgets(
      'Bare course route auto-redirects to first module when modules exist',
      (tester) async {
        const courseId = 'course-1';

        const fakeModule = CourseModule(
          id: 'module-1',
          title: 'Test Module',
          order: 1,
          totalLessons: 10,
          doneLessons: 0,
        );

        await _pumpRouterApp(
          tester,
          extraOverrides: [
            courseModulesProvider.overrideWith((ref, id) async {
              expect(id, courseId);
              return [fakeModule];
            }),
          ],
        );

        _router.go('/home/course/$courseId');

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(TrackDetailPage), findsOneWidget);
      },
    );
  });

  group('AppRouter errorBuilder', () {
    testWidgets(
      'Unknown route shows Page Not Found screen and Home button navigates to /home',
      (tester) async {
        await _pumpRouterApp(tester);

        _router.go('/this-route-does-not-exist');

        await tester.pump();

        while (true) {
          final exception = tester.takeException();
          if (exception == null) break;
        }

        await tester.pump();

        expect(find.text('Page Not Found'), findsOneWidget);

        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        expect(find.byType(LearnPage), findsOneWidget);
      },
    );
  });
}
