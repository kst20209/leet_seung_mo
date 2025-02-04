class PurchaseResult {
  final bool success;
  final String status; // 'completed', 'canceled', 'failed'
  final String? message;

  PurchaseResult({
    required this.success,
    required this.status,
    this.message,
  });
}

class IAPProduct {
  final String id;
  final String title;
  final int points;
  final double price;

  IAPProduct({
    required this.id,
    required this.title,
    required this.points,
    required this.price,
  });
}
