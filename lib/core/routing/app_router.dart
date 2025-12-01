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
import 'package:mobile_app/features/catalog/presentation/providers/module_providers.dart';
import 'package:mobile_app/features/help/presentation/pages/contact_us_page.dart';
import 'package:mobile_app/features/help/presentation/pages/help_center_page.dart';
import 'package:mobile_app/features/launch/splash_page.dart';
import 'package:mobile_app/features/leaderboard/leaderboard_page.dart';
import 'package:mobile_app/features/legal/terms_of_service_page.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_app/ui/app_shell.dart';
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
          final from = st.uri.queryParameters['from'];
          final returnTo = _resolveReturnTo(from);
          return LoginPage(returnTo: returnTo);
        },
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (ctx, st) {
          final from = st.uri.queryParameters['from'];
          final returnTo = _resolveReturnTo(from);
          return SignUpPage(returnTo: returnTo);
        },
      ),
      GoRoute(
        path: '/terms',
        name: 'termsOfService',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: '/help-center',
        name: 'helpCenter',
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: '/contact-us',
        name: 'contactUs',
        builder: (context, state) => const ContactUsPage(),
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
                    path: 'course/:courseId',
                    builder: (ctx, st) {
                      final courseId = st.pathParameters['courseId']!;
                      final path = st.uri.path;
                      final base = '/home/course/$courseId';
                      final isExact = path == base || path == '$base/';
                      return _CourseAutoRedirect(
                        courseId: courseId,
                        isExact: isExact,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'module/:moduleId',
                        builder: (ctx, st) {
                          final courseId = st.pathParameters['courseId']!;
                          final moduleId = st.pathParameters['moduleId']!;
                          return TrackDetailPage(
                            courseId: courseId,
                            moduleId: moduleId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'lesson/:lessonId',
                            builder: (ctx, st) => LessonPage(
                              courseId: st.pathParameters['courseId']!,
                              moduleId: st.pathParameters['moduleId']!,
                              lessonId: st.pathParameters['lessonId']!,
                            ),
                          ),
                        ],
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
                routes: [
                  GoRoute(
                    path: 'welcome',
                    builder: (ctx, st) {
                      final from = st.uri.queryParameters['from'];
                      return WelcomePage(returnTo: from);
                    },
                  ),
                ],
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

      final session = auth.valueOrNull;
      final isAuthed = session != null;

      final loc = state.matchedLocation;
      final uri = state.uri;

      final isRoot = loc == '/' || loc == SplashPage.routePath;
      final isAuthFlow = loc.startsWith('/auth/');
      final isWelcome =
          loc == '/profile/welcome' || loc.startsWith('/profile/welcome');
      final isOnboarding = loc == OnboardingPage.routePath;

      if (!isAuthed) {
        if (_isProtected(loc)) {
          final from = Uri.encodeComponent(uri.toString());
          return '/profile/welcome?from=$from';
        }
        return null;
      }

      if (isRoot || isOnboarding || isAuthFlow || isWelcome) {
        final from = uri.queryParameters['from'];
        final safe = _sanitizeReturn(from);
        return safe ?? '/profile';
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
  if (loc == '/profile/welcome' || loc.startsWith('/profile/welcome')) {
    return false;
  }
  return loc == '/profile' || loc.startsWith('/profile/');
}

String? _sanitizeReturn(String? from) {
  if (from == null || from.isEmpty) return null;
  if (from == '/profile/welcome' || from.startsWith('/auth/')) {
    return '/profile';
  }
  return from;
}

String _resolveReturnTo(String? from) {
  final safe = _sanitizeReturn(from);
  return safe ?? '/profile';
}

class _CourseAutoRedirect extends ConsumerWidget {
  const _CourseAutoRedirect({required this.courseId, required this.isExact});

  final String courseId;
  final bool isExact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isExact) return const SizedBox.shrink();

    final modulesAsync = ref.watch(courseModulesProvider(courseId));
    return modulesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Failed to load modules: $e'))),
      data: (modules) {
        if (modules.isEmpty) {
          return const Scaffold(body: Center(child: Text('No modules yet')));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          final first = modules.first;

          context.go('/home/course/$courseId/module/${first.id}');
        });

        return const SizedBox.shrink();
      },
    );
  }
}
