import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';

void main() {
  group('Profile', () {
    test('constructs with given fields', () {
      const profile = Profile(
        id: 'user-1',
        username: 'codeforge',
        fullName: 'Code Forge',
        bio: 'Learn to code with quests',
        avatarUrl: 'https://example.com/avatar.png',
      );

      expect(profile.id, 'user-1');
      expect(profile.username, 'codeforge');
      expect(profile.fullName, 'Code Forge');
      expect(profile.bio, 'Learn to code with quests');
      expect(profile.avatarUrl, 'https://example.com/avatar.png');
      expect(profile.updatedAt, isNull);
    });

    test('fromMap maps all fields and parses updatedAt', () {
      const updatedAtString = '2025-11-13T20:00:00.000Z';
      final map = <String, dynamic>{
        'id': 'user-42',
        'username': 'wizard',
        'full_name': 'Code Wizard',
        'bio': 'Casting Dart spells',
        'avatar_url': 'https://example.com/wizard.png',
        'updated_at': updatedAtString,
      };

      final profile = Profile.fromMap(map);

      expect(profile.id, 'user-42');
      expect(profile.username, 'wizard');
      expect(profile.fullName, 'Code Wizard');
      expect(profile.bio, 'Casting Dart spells');
      expect(profile.avatarUrl, 'https://example.com/wizard.png');
      expect(profile.updatedAt, DateTime.parse(updatedAtString));
    });

    test('fromMap allows null updatedAt', () {
      final map = <String, dynamic>{
        'id': 'user-no-updated-at',
        'username': 'no-updated',
        'full_name': 'No Updated At',
        'bio': null,
        'avatar_url': null,
        'updated_at': null,
      };

      final profile = Profile.fromMap(map);

      expect(profile.id, 'user-no-updated-at');
      expect(profile.username, 'no-updated');
      expect(profile.fullName, 'No Updated At');
      expect(profile.bio, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.updatedAt, isNull);
    });

    test('copyWith overrides provided fields and keeps others', () {
      final original = Profile(
        id: 'user-1',
        username: 'old-username',
        fullName: 'Old Name',
        bio: 'Old bio',
        avatarUrl: 'https://example.com/old.png',
        updatedAt: DateTime.utc(2025, 11, 10),
      );

      final updated = original.copyWith(
        username: 'new-username',
        bio: 'New bio',
      );

      expect(updated.id, original.id);
      expect(updated.username, 'new-username');
      expect(updated.fullName, original.fullName);
      expect(updated.bio, 'New bio');
      expect(updated.avatarUrl, original.avatarUrl);
      expect(updated.updatedAt, original.updatedAt);
    });

    test('copyWith keeps username and bio when null is passed', () {
      final original = Profile(
        id: 'user-2',
        username: 'original-username',
        fullName: 'Original Name',
        bio: 'Original bio',
        avatarUrl: 'https://example.com/original.png',
        updatedAt: DateTime.utc(2025, 11, 11),
      );

      final copy = original.copyWith(username: null, bio: null);

      expect(copy.username, 'original-username');
      expect(copy.bio, 'Original bio');
      expect(copy.id, original.id);
      expect(copy.fullName, original.fullName);
      expect(copy.avatarUrl, original.avatarUrl);
      expect(copy.updatedAt, original.updatedAt);
    });

    test('toUpdateMap includes only non-null fields', () {
      const profile = Profile(
        id: 'user-1',
        username: 'codeforge',
        fullName: 'Code Forge',
        avatarUrl: 'https://example.com/avatar.png',
      );

      final map = profile.toUpdateMap();

      expect(map['username'], 'codeforge');
      expect(map['full_name'], 'Code Forge');
      expect(map.containsKey('bio'), isFalse);
      expect(map['avatar_url'], 'https://example.com/avatar.png');

      expect(map.containsKey('updated_at'), isTrue);
      expect(map['updated_at'], isA<String>());
      expect(DateTime.tryParse(map['updated_at'] as String), isNotNull);
    });

    test(
      'toUpdateMap with all optional fields null includes only updated_at',
      () {
        const profile = Profile(id: 'user-1');

        final map = profile.toUpdateMap();

        expect(map.length, 1);
        expect(map.containsKey('updated_at'), isTrue);
        expect(map['updated_at'], isA<String>());
        expect(DateTime.tryParse(map['updated_at'] as String), isNotNull);
      },
    );
  });
}
