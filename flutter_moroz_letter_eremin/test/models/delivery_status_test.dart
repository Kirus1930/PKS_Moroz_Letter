// test/models/delivery_status_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_moroz_letter_eremin/models/delivery_status.dart';

void main() {
  group('DeliveryTracker Tests', () {
    test('Status descriptions are correct', () {
      final tracker = DeliveryTracker(
        currentStatus: DeliveryStatus.letterCreated,
        daysUntilNewYear: 10,
      );

      expect(tracker.statusDescription, equals('Письмо создано'));

      final tracker2 = DeliveryTracker(
        currentStatus: DeliveryStatus.delivered,
        daysUntilNewYear: 0,
      );

      expect(tracker2.statusDescription, equals('Подарки доставлены!'));
    });

    test('All statuses have descriptions', () {
      for (final status in DeliveryStatus.values) {
        final tracker = DeliveryTracker(
          currentStatus: status,
          daysUntilNewYear: 5,
        );
        expect(tracker.statusDescription, isNotEmpty);
      }
    });
  });
}
