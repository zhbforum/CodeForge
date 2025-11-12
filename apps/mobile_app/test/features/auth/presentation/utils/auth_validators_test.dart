import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/utils/auth_validators.dart';

void main() {
  group('Auth validators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('no_at.com'), isNotNull);
      expect(AuthValidators.email('a@b.c'), isNull);
    });

    test('password (required, min 6 chars)', () {
      expect(AuthValidators.password(''), isNotNull);
      expect(AuthValidators.password('12345'), isNotNull);
      expect(AuthValidators.password('abcdef'), isNull);
      expect(AuthValidators.password('Abcdef1'), isNull);
    });

    group('confirm password', () {
      test('null -> asks to repeat', () {
        expect(
          AuthValidators.confirm(null, 'abcdef'),
          equals('Repeat password please'),
        );
      });

      test('empty -> asks to repeat', () {
        expect(
          AuthValidators.confirm('', 'abcdef'),
          equals('Repeat password please'),
        );
      });

      test('mismatch -> shows mismatch error', () {
        expect(
          AuthValidators.confirm('abcdef', 'abcdef1'),
          equals('Passwords do not match'),
        );
      });

      test('match -> ok (null)', () {
        expect(AuthValidators.confirm('secret123', 'secret123'), isNull);
      });
    });
  });
}
