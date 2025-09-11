import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';

// TODO(killursxlf): swap to SupabaseProfileRepository later
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => MockProfileRepository());

final profileProvider =
    StateNotifierProvider<ProfileController, AsyncValue<Profile>>(
  (ref) => ProfileController(ref.read(profileRepositoryProvider))..load(),
);

class ProfileController extends StateNotifier<AsyncValue<Profile>> {
  ProfileController(this._repo) : super(const AsyncLoading());

  final ProfileRepository _repo;

  Future<void> load() async {
    try {
      final p = await _repo.load();
      state = AsyncData(p);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBio(String? bio) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(bio: bio));
    await _repo.updateBio(bio);
  }

  Future<void> updateAvatar(String url) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(avatarUrl: url));
    await _repo.updateAvatar(url);
  }
}
