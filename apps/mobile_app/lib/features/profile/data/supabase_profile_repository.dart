import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._db);
  final SupabaseClient _db;

  String _uidOrThrow() {
    final u = _db.auth.currentUser;
    if (u == null) throw StateError('Not authenticated');
    return u.id;
  }

  @override
  Future<Profile> load() async {
    final uid = _uidOrThrow();

    final row = await _db.from('profiles').select().eq('id', uid).maybeSingle();
    if (row != null) return Profile.fromMap(row);

    final email = _db.auth.currentUser!.email ?? '';
    final suggestedUsername = (email.isNotEmpty ? 
    email.split('@').first : uid.substring(0, 8)).toLowerCase();

    final created = await _db
        .from('profiles')
        .upsert({
          'id': uid,
          'username': suggestedUsername,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'id')
        .select()
        .single();

    return Profile.fromMap(created);
  }

  @override
  Future<void> updateAvatar(String url) async {
    final uid = _uidOrThrow();
    await _db.from('profiles').update({
      'avatar_url': url,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', uid);
  }

  Future<void> ensureProfile() async {
    final uid = _uidOrThrow();
    await _db
        .from('profiles')
        .upsert({
          'id': uid,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'id')
        .select()
        .maybeSingle();
  }

  @override
  Future<void> updateFullName(String? fullName) async {
    final uid = _uidOrThrow();
    await _db.from('profiles').update({
      'full_name': fullName,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', uid);
  }

  @override
  Future<void> updateBio(String? bio) async {
    final uid = _uidOrThrow();
    await _db.from('profiles').update({
      'bio': bio,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', uid);
  }
}
