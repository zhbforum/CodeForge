import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/services/auth_refresh_provider.dart';
import 'package:mobile_app/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/signup_page.dart';
import 'package:mobile_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/catalog/presentation/pages/learn_page.dart';
import 'package:mobile_app/features/catalog/presentation/pages/lesson_page.dart';
import 'package:mobile_app/features/catalog/presentation/pages/track_detail_page.dart';
import 'package:mobile_app/features/launch/splash_page.dart';
import 'package:mobile_app/features/leaderboard/leaderboard_page.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:mobile_app/features/practice/practice_page.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_app/features/shell/presentation/pages/app_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(authRefreshProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,

    routes: [
      GoRoute(path: '/', redirect: (_, __) => SplashPage.routePath),

      GoRoute(
        path: SplashPage.routePath,
        builder: (_, __) => const SplashPage(),
      ),

      GoRoute(
        path: OnboardingPage.routePath,
        builder: (_, __) => const OnboardingPage(),
      ),

      GoRoute(
        path: '/auth/login',
        builder: (ctx, st) {
          final from = st.uri.queryParameters['from'] ?? '/profile';
          return LoginPage(returnTo: from);
        },
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (ctx, st) {
          final from = st.uri.queryParameters['from'] ?? '/profile';
          return SignUpPage(returnTo: from);
        },
      ),
      GoRoute(
        path: WelcomePage.routePath,
        builder: (ctx, st) {
          final from = st.uri.queryParameters['from'];
          return WelcomePage(returnTo: from);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) => AppShell(navShell: navShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: LearnPage()),
                routes: [
                  GoRoute(
                    path: 'course/:id',
                    builder: (ctx, st) {
                      final courseId = st.pathParameters['id']!;
                      return TrackDetailPage(courseId: courseId);
                    },
                    routes: [
                      GoRoute(
                        path: 'lesson/:lessonId',
                        builder: (ctx, st) => LessonPage(
                          courseId: st.pathParameters['id']!,
                          lessonId: st.pathParameters['lessonId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: PracticePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: LeaderboardPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (ctx, state) {
                  final uid = Supabase.instance.client.auth.currentUser?.id;
                  return NoTransitionPage(
                    child: KeyedSubtree(
                      key: ValueKey(uid),
                      child: const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final auth = ref.read(authSessionProvider);

      if (auth.isLoading) {
        return state.matchedLocation == SplashPage.routePath
            ? null
            : SplashPage.routePath;
      }

      final session = Supabase.instance.client.auth.currentSession;
      final isAuthed = session != null;

      final loc = state.matchedLocation;
      final uri = state.uri;

      final isRoot = loc == '/' || loc == SplashPage.routePath;
      final isAuthFlow = loc.startsWith('/auth/');
      final isWelcome = loc == WelcomePage.routePath;
      final isOnboarding = loc == OnboardingPage.routePath;

      if (!isAuthed) {
        if (_isProtected(loc)) {
          final from = Uri.encodeComponent(uri.toString());
          return '${WelcomePage.routePath}?from=$from';
        }
        return null;
      }

      if (isRoot || isOnboarding || isAuthFlow || isWelcome) {
        final from = uri.queryParameters['from'];
        return from ?? '/profile';
      }

      return null;
    },

    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(state.error?.toString() ?? 'Unknown error'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

bool _isProtected(String loc) {
  return loc.startsWith('/profile');
}
