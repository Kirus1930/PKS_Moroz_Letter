import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_moroz_letter_eremin/services/parent_auth_service.dart';

void main() {
  group('ParentAuthService Tests', () {
    setUp(() {
      // Очищаем SharedPreferences перед каждым тестом
      SharedPreferences.setMockInitialValues({});
    });

    test('Default PIN is set on init', () async {
      await ParentAuthService.init();

      final isSetup = await ParentAuthService.isPinSetup();
      expect(isSetup, isTrue);

      final isValid = await ParentAuthService.verifyPin('1234');
      expect(isValid, isTrue);
    });

    test('Verify PIN returns correct result', () async {
      await ParentAuthService.init();

      expect(await ParentAuthService.verifyPin('1234'), isTrue);
      expect(await ParentAuthService.verifyPin('0000'), isFalse);
    });

    test('Set new PIN works correctly', () async {
      await ParentAuthService.init();
      await ParentAuthService.setPin('9999');

      expect(await ParentAuthService.verifyPin('9999'), isTrue);
      expect(await ParentAuthService.verifyPin('1234'), isFalse);
    });

    test('Clear PIN removes PIN', () async {
      await ParentAuthService.init();
      await ParentAuthService.clearPin();

      expect(await ParentAuthService.isPinSetup(), isFalse);
    });
  });
}
