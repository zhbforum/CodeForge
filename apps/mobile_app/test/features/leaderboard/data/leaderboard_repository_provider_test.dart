import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/leaderboard/data/leaderboard_repository_provider.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sf;

void main() {
  group('leaderboardRepositoryProvider', () {
    test(
      'returns SupabaseLeaderboardRepository and memoizes instance (override)',
      () {
        final fakeClient = sf.SupabaseClient(
          'https://example-project.supabase.co',
          'public-anon-key',
        );

        final container = ProviderContainer(
          overrides: [supabaseClientProvider.overrideWithValue(fakeClient)],
        );
        addTearDown(container.dispose);

        final repo1 = container.read(leaderboardRepositoryProvider);
        expect(repo1, isA<SupabaseLeaderboardRepository>());

        final repo2 = container.read(leaderboardRepositoryProvider);
        expect(identical(repo1, repo2), isTrue);
      },
    );

    test(
      'default supabaseClientProvider hits Supabase.instance.client',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        SharedPreferences.setMockInitialValues({});

        await sf.Supabase.initialize(
          url: 'https://example-project.supabase.co',
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.test',
        );
        sf.Supabase.instance.client.auth.stopAutoRefresh();

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final client = container.read(supabaseClientProvider);
        expect(client, isA<sf.SupabaseClient>());
      },
    );
  });
}
