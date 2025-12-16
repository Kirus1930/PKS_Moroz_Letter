enum DeliveryStatus {
  letterCreated,
  letterSent,
  deliveredToSanta,
  giftsPreparing,
  santaInSleigh,
  onTheWay,
  delivered,
}

class DeliveryTracker {
  final DeliveryStatus currentStatus;
  final DateTime? statusChangedAt;
  final int daysUntilNewYear;

  DeliveryTracker({
    required this.currentStatus,
    this.statusChangedAt,
    required this.daysUntilNewYear,
  });

  String get statusDescription {
    switch (currentStatus) {
      case DeliveryStatus.letterCreated:
        return "Письмо создано";
      case DeliveryStatus.letterSent:
        return "Письмо отправлено";
      case DeliveryStatus.deliveredToSanta:
        return "Письмо доставлено Деду Морозу";
      case DeliveryStatus.giftsPreparing:
        return "Подарки готовятся";
      case DeliveryStatus.santaInSleigh:
        return "Дед Мороз сел в сани";
      case DeliveryStatus.onTheWay:
        return "Дед Мороз в пути";
      case DeliveryStatus.delivered:
        return "Подарки доставлены!";
    }
  }
}
