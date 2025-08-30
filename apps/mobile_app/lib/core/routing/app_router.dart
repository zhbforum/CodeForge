import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/learn_page.dart';
import 'package:mobile_app/features/catalog/track_detail_page.dart';
import 'package:mobile_app/features/launch/splash_page.dart';
import 'package:mobile_app/features/leaderboard/leaderboard_page.dart';
import 'package:mobile_app/features/onboarding/onboarding_page.dart';
import 'package:mobile_app/features/practice/practice_page.dart';
import 'package:mobile_app/features/profile/profile_page.dart';
import 'package:mobile_app/features/shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
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
                    path: 'track/:id',
                    builder: (ctx, st) {
                      final idParam = st.pathParameters['id']!;
                      final trackId = TrackId.values.firstWhere(
                        (e) => e.name == idParam,
                      );
                      final title = switch (trackId) {
                        TrackId.fullstack => 'Full-Stack Developer',
                        TrackId.python => 'Python Developer',
                        TrackId.backend => 'Back-End Developer',
                        TrackId.vanillaJs => 'Vanilla JS',
                        TrackId.typescript => 'TypeScript',
                        TrackId.html => 'HTML',
                        TrackId.css => 'CSS',
                      };
                      return TrackDetailPage(trackId: trackId, title: title);
                    },
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
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],

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
