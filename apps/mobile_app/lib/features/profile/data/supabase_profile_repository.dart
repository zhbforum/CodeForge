import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._api, this._db);

  final ApiService _api;
  final SupabaseClient _db;

  String _uidOrThrow() {
    final u = _db.auth.currentUser;
    if (u == null) throw StateError('Not authenticated');
    return u.id;
  }

  @override
  Future<Profile> load() async {
    final uid = _uidOrThrow();

    final rows = await _api.query(
      table: 'profiles',
      select: '*',
      filters: {'id': uid},
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return Profile.fromMap(rows.first);
    }

    final email = _db.auth.currentUser!.email ?? '';
    final suggestedUsername =
        (email.isNotEmpty ? email.split('@').first : uid.substring(0, 8))
            .toLowerCase();

    final now = DateTime.now().toUtc().toIso8601String();

    await _api.upsert(
      table: 'profiles',
      values: {
        'id': uid,
        'username': suggestedUsername,
        'updated_at': now,
      },
      onConflict: 'id',
    );

    final createdRows = await _api.query(
      table: 'profiles',
      select: '*',
      filters: {'id': uid},
      limit: 1,
    );

    if (createdRows.isEmpty) {
      throw StateError('Failed to create profile');
    }

    return Profile.fromMap(createdRows.first);
  }

  @override
  Future<void> updateAvatar(String url) async {
    final uid = _uidOrThrow();
    final now = DateTime.now().toUtc().toIso8601String();

    await _api.upsert(
      table: 'profiles',
      values: {
        'id': uid,
        'avatar_url': url,
        'updated_at': now,
      },
      onConflict: 'id',
    );
  }

  Future<void> ensureProfile() async {
    final uid = _uidOrThrow();
    final now = DateTime.now().toUtc().toIso8601String();

    await _api.upsert(
      table: 'profiles',
      values: {
        'id': uid,
        'updated_at': now,
      },
      onConflict: 'id',
    );
  }

  @override
  Future<void> updateFullName(String? fullName) async {
    final uid = _uidOrThrow();
    final now = DateTime.now().toIso8601String();

    await _api.upsert(
      table: 'profiles',
      values: {
        'id': uid,
        'full_name': fullName,
        'updated_at': now,
      },
      onConflict: 'id',
    );
  }

  @override
  Future<void> updateBio(String? bio) async {
    final uid = _uidOrThrow();
    final now = DateTime.now().toUtc().toIso8601String();

    await _api.upsert(
      table: 'profiles',
      values: {
        'id': uid,
        'bio': bio,
        'updated_at': now,
      },
      onConflict: 'id',
    );
  }
}
