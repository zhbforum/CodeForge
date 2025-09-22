import 'package:mobile_app/features/profile/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> load();
  Future<void> updateBio(String? bio);
  Future<void> updateAvatar(String url);
}

class MockProfileRepository implements ProfileRepository {
  Profile _p = const Profile(id: 'u_1', displayName: 'Guest', avatarUrl: '');

  @override
  Future<Profile> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _p;
  }

  @override
  Future<void> updateBio(String? bio) async {
    _p = _p.copyWith(bio: bio);
  }

  @override
  Future<void> updateAvatar(String url) async {
    _p = _p.copyWith(avatarUrl: url);
  }
}
