import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:mobile_app/features/profile/presentation/widgets/profile_edit_dialog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const initialProfile = Profile(
    id: 'user-1',
    fullName: 'Old Name',
    bio: 'Old bio',
  );

  ProviderScope buildAppWithDialog({
    required Profile profile,
    required ProfileRepository repo,
  }) {
    return ProviderScope(
      overrides: [
        authStateStreamProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        isAuthenticatedProvider.overrideWithValue(true),
        currentUserIdProvider.overrideWithValue('user-1'),

        profileProvider.overrideWith((ref) {
          final controller = ProfileController(repo)
            ..state = AsyncData<Profile>(profile);
          return controller;
        }),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => ProfileEditDialog.show(context),
                  child: const Text('Open dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  group('ProfileEditDialog', () {
    testWidgets('saves updated name and bio successfully and closes dialog', (
      tester,
    ) async {
      final repo = _MockProfileRepository();

      when(() => repo.updateFullName(any())).thenAnswer((_) async {});
      when(() => repo.updateBio(any())).thenAnswer((_) async {});
      when(repo.load).thenAnswer((_) async => initialProfile);

      await tester.pumpWidget(
        buildAppWithDialog(profile: initialProfile, repo: repo),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      final nameField = find.widgetWithText(TextFormField, 'Old Name');
      final bioField = find.widgetWithText(TextFormField, 'Old bio');

      expect(nameField, findsOneWidget);
      expect(bioField, findsOneWidget);

      await tester.enterText(nameField, 'New Name');
      await tester.enterText(bioField, 'New bio');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows error SnackBar when save fails and keeps dialog open', (
      tester,
    ) async {
      final repo = _MockProfileRepository();

      when(() => repo.updateFullName(any())).thenThrow(Exception('boom'));
      when(() => repo.updateBio(any())).thenAnswer((_) async {});
      when(repo.load).thenAnswer((_) async => initialProfile);

      await tester.pumpWidget(
        buildAppWithDialog(profile: initialProfile, repo: repo),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      final nameField = find.widgetWithText(TextFormField, 'Old Name');
      final bioField = find.widgetWithText(TextFormField, 'Old bio');

      await tester.enterText(nameField, 'Error Name');
      await tester.enterText(bioField, 'Error bio');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.tap(saveButton);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AlertDialog), findsOneWidget);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Error saving:'), findsOneWidget);
    });
  });
}
