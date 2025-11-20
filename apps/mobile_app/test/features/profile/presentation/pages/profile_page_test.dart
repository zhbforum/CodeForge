import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:mobile_app/features/profile/presentation/widgets/avatar_block.dart';
import 'package:mobile_app/features/settings/presentation/widgets/settings_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

class _DummyProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const emptyProfile = Profile(id: 'test-id');

  const filledProfile = Profile(
    id: 'x',
    username: 'nick',
    fullName: 'John Doe',
    bio: 'Something',
  );

  Widget buildApp({
    required Profile profile,
    required bool isLoggedIn,
    GoRouter? router,
  }) {
    final dummyRepo = _DummyProfileRepository();

    return ProviderScope(
      overrides: [
        authStateStreamProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        isAuthenticatedProvider.overrideWithValue(isLoggedIn),
        profileProvider.overrideWith((ref) {
          final ctrl = ProfileController(dummyRepo)
            ..state = AsyncData<Profile>(profile);
          return ctrl;
        }),
      ],
      child: router == null
          ? const MaterialApp(home: ProfilePage())
          : MaterialApp.router(routerConfig: router),
    );
  }

  group('ProfilePage', () {
    testWidgets('renders fallback for empty profile + needsSetup flow', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(profile: emptyProfile, isLoggedIn: true),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      expect(find.text('Guest'), findsOneWidget);

      final bioText = find.text('Add a bio');
      expect(bioText, findsOneWidget);

      expect(
        find.text('Fill in your name and bio to complete your profile.'),
        findsOneWidget,
      );

      final editProfileButton = find.widgetWithText(
        FilledButton,
        'Edit Profile',
      );
      expect(editProfileButton, findsOneWidget);

      await tester.tap(editProfileButton);
      await tester.pump(const Duration(milliseconds: 100));

      final bioInkWellFinder = find.ancestor(
        of: bioText,
        matching: find.byType(InkWell),
      );
      expect(bioInkWellFinder, findsOneWidget);

      final inkWellElement = tester.element(bioInkWellFinder);
      final inkWellWidget = inkWellElement.widget as InkWell;
      inkWellWidget.onTap?.call();

      final avatarFinder = find.byType(AvatarBlock);
      final avatarWidget = tester.widget<AvatarBlock>(avatarFinder);
      avatarWidget.onEditAvatar.call();
    });

    testWidgets('renders completed profile (full branches hit)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(profile: filledProfile, isLoggedIn: true),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('John Doe'), findsOneWidget);

      expect(find.text('Something'), findsOneWidget);

      final avatar = tester.widget<AvatarBlock>(find.byType(AvatarBlock));
      expect(avatar.seed, equals('nick'));
    });

    testWidgets('opens settings bottom sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(profile: emptyProfile, isLoggedIn: true),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SettingsBottomSheet), findsOneWidget);
    });

    testWidgets('shows Sign In when logged out', (tester) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/auth/login',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Login page'))),
          ),
        ],
      );

      await tester.pumpWidget(
        buildApp(profile: emptyProfile, isLoggedIn: false, router: router),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final signInButton = find.widgetWithText(FilledButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Login page'), findsOneWidget);
    });

    testWidgets('shows loading skeleton', (tester) async {
      final dummyRepo = _DummyProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateStreamProvider.overrideWith(
              (ref) => const Stream<AuthState>.empty(),
            ),
            isAuthenticatedProvider.overrideWithValue(true),
            profileProvider.overrideWith((ref) {
              return ProfileController(dummyRepo);
            }),
          ],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );

      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  });
}
