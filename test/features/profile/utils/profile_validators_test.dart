import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/utils/profile_validators.dart';

void main() {
  group('ProfileValidators.nameAllowed', () {
    test(
      'allows latin letters/digits/hyphen/dot/space/apostrophe/umlauts/cyrillic',
      () {
        expect(ProfileValidators.nameAllowed.hasMatch('A'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('z'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('0'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('-'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('.'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch(' '), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch("'"), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('Ä'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('ü'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('ß'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('Ж'), isTrue);
        expect(ProfileValidators.nameAllowed.hasMatch('ї'), isTrue);
      },
    );

    test('disallows emoji and newline', () {
      expect(ProfileValidators.nameAllowed.hasMatch('😊'), isFalse);
      expect(ProfileValidators.nameAllowed.hasMatch('\n'), isFalse);
    });
  });

  group('ProfileValidators.nameFilter', () {
    test('filters out disallowed characters (emoji, newline)', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: 'Test😊\nTested');
      final result = ProfileValidators.nameFilter.formatEditUpdate(
        oldValue,
        newValue,
      );
      expect(result.text, 'TestTested');
    });

    test('passes through allowed characters', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: "Jürgen O'Neill-Ганна.");
      final result = ProfileValidators.nameFilter.formatEditUpdate(
        oldValue,
        newValue,
      );
      expect(result.text, "Jürgen O'Neill-Ганна.");
    });
  });

  group('ProfileValidators.validateFullName', () {
    test('empty string -> Name is required', () {
      expect(ProfileValidators.validateFullName('   '), 'Name is required');
    });

    test('length > nameMax -> Max {nameMax} characters', () {
      final tooLong = List.filled(ProfileValidators.nameMax + 1, 'a').join();
      expect(
        ProfileValidators.validateFullName(tooLong),
        'Max ${ProfileValidators.nameMax} characters',
      );
    });

    test('exactly nameMax characters — valid', () {
      final exact = List.filled(ProfileValidators.nameMax, 'a').join();
      expect(ProfileValidators.validateFullName(exact), isNull);
    });

    test('disallowed characters -> error', () {
      expect(
        ProfileValidators.validateFullName('Test 😀'),
        "Only letters, numbers, spaces, '.', '-' and \"'\"",
      );
    });

    test('space normalization and validity', () {
      expect(ProfileValidators.validateFullName('  Test   Name  '), isNull);
    });

    test('unicode support (umlauts/cyrillic/apostrophe/hyphen/dot)', () {
      expect(
        ProfileValidators.validateFullName("Jürgen ß. Пилипчук-О'Нілл"),
        isNull,
      );
    });
  });

  group('ProfileValidators.validateBio', () {
    test('bio > bioMax -> Max {bioMax} characters', () {
      final tooLong = List.filled(ProfileValidators.bioMax + 1, 'b').join();
      expect(
        ProfileValidators.validateBio(tooLong),
        'Max ${ProfileValidators.bioMax} characters',
      );
    });

    test('bio exactly bioMax — valid', () {
      final exact = List.filled(ProfileValidators.bioMax, 'b').join();
      expect(ProfileValidators.validateBio(exact), isNull);
    });

    test('control characters are not allowed', () {
      expect(
        ProfileValidators.validateBio('hello\r\nworld'),
        'Control characters are not allowed',
      );
      expect(
        ProfileValidators.validateBio('zero\u0000byte'),
        'Control characters are not allowed',
      );
      expect(
        ProfileValidators.validateBio('tab\thello'),
        'Control characters are not allowed',
      );
    });

    test('valid bio with extra spaces trimmed', () {
      expect(ProfileValidators.validateBio('   Passionate dev  '), isNull);
    });
  });

  group('ProfileValidators.normalize helpers', () {
    test('normalizeName collapses spaces', () {
      expect(ProfileValidators.normalizeName('  Test   Name  '), 'Test Name');
    });

    test('normalizeBio trims edges', () {
      expect(ProfileValidators.normalizeBio('  Hello world  '), 'Hello world');
    });
  });
}
