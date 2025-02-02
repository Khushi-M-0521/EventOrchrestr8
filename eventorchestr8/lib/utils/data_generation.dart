import 'dart:math';

class DataGenerator {
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static int generateRandomPrice() {
    return Random().nextInt(500) + 50; // Random price between 50 and 550
  }

  static int generateRandomPaymentId() {
    return DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000);
  }

  static Map<String, dynamic> generateData() {
    return {
      "eventId": generateRandomString(10),
      "userId": generateRandomString(12),
      "uuid": generateRandomString(16),
      "price": generateRandomPrice(),
      "paymentId": generateRandomPaymentId(),
    };
  }
}
