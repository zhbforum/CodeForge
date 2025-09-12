import 'package:mobile_app/features/profile/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> load();
  Future<void> updateBio(String? bio);
  Future<void> updateAvatar(String url);
}

class MockProfileRepository implements ProfileRepository {
  Profile _p = const Profile(
    id: 'u_1',
    displayName: 'Guest',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDyuskrtSKMolDvy2LlGZGaWWBQfJibOP9eKgDZBWS2_49JkvD3PEEYjFyCIYugd7O9zxVuP2ExLn-ghO-Al6urv-0Ijvcb5A-_QUuFVnE2s6vPyZeGTv8v86K2SMspWYcZYBRNEfCEP6BL7yv05FVZx6Wdf13U1HZbGpCob-QxEUABAXxyAP9sDTIWLKQOSfrqTtF4N_vDBLSpBWvZa9vOC3W5DSlVECa6CAYY2pAHx35EPneq_cTb_a-63te8CT9KfBDSTmgIr68',
  );

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
