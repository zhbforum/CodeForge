import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/ui/app_shell.dart';

void main() {
  testWidgets('AppShell builds and switches tabs', (tester) async {
    final router = GoRouter(
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navShell) => AppShell(navShell: navShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/learn',
                  builder: (context, state) =>
                      const Center(child: Text('Learn page')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/table',
                  builder: (context, state) =>
                      const Center(child: Text('Table page')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) =>
                      const Center(child: Text('Profile page')),
                ),
              ],
            ),
          ],
        ),
      ],
      initialLocation: '/learn',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Learn page'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Profile page'), findsOneWidget);
  });
}
