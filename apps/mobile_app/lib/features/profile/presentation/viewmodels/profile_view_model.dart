import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/data/profile_repository_provider.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileController, AsyncValue<Profile>>(
      name: 'profileProvider',
      (ref) {
        final repo = ref.read(profileRepositoryProvider);
        final ctrl = ProfileController(repo);

        final uid = ref.watch(currentUserIdProvider);

        if (uid == null) {
          ctrl.setUnauthenticated();
        } else {
          Supabase.instance.client
              .rpc<void>('ensure_profile')
              .catchError((_) {});
          ctrl.load();
        }

        return ctrl;
      },
    );

class ProfileController extends StateNotifier<AsyncValue<Profile>> {
  ProfileController(this._repo) : super(const AsyncLoading());

  final ProfileRepository _repo;

  void setUnauthenticated() {
    state = AsyncError(StateError('Not authenticated'), StackTrace.empty);
  }

  Future<void> load() async {
    try {
      state = const AsyncLoading();
      final p = await _repo.load();
      state = AsyncData(p);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() => state = const AsyncLoading();

  Future<void> updateFullName(String? fullName) async {
    try {
      final currentProfile = state.valueOrNull;
      if (currentProfile == null) {
        throw StateError('No profile data available');
      }
      await _repo.updateFullName(fullName);
      await load();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateBio(String? bio) async {
    try {
      final currentProfile = state.valueOrNull;
      if (currentProfile == null) {
        throw StateError('No profile data available');
      }
      await _repo.updateBio(bio);
      await load();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateAvatar(String url) async {
    try {
      final currentProfile = state.valueOrNull;
      if (currentProfile == null) {
        throw StateError('No profile data available');
      }
      await _repo.updateAvatar(url);
      await load();
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
