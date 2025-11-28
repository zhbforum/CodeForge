import 'package:mobile_app/features/profile/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> load();
  Future<void> updateBio(String? bio);
  Future<void> updateAvatar(String url);
  Future<void> updateFullName(String? fullName);
}
