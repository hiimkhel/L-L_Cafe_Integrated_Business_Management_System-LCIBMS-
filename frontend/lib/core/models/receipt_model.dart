class ReceiptData {
  final String orderNumber;
  final String clientName;
  final DateTime dateTime;
  final OrderType orderType;
  final List<OrderItem> items;
  final PaymentMethod paymentMethod;
  final double cashReceived;
  final double change;

  const ReceiptData({
    required this.orderNumber,
    required this.clientName,
    required this.dateTime,
    required this.orderType,
    required this.items,
    required this.paymentMethod,
    required this.cashReceived,
    required this.change,
  });

  double get materialCost => items.fold(0, (sum, i) => sum + i.total);
  double get grandTotal => materialCost;

  String get formattedDate {
    final d = dateTime;
    return '${d.year}-${_p(d.month)}-${_p(d.day)} ${_p(d.hour)}:${_p(d.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}


class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;
  String get displayName => '${name.toUpperCase()} X$quantity';
}

enum OrderType { walkIn, dineIn, takeOut }

extension OrderTypeLabel on OrderType {
  String get label {
    switch (this) {
      case OrderType.walkIn:
        return 'WALK-IN';
      case OrderType.dineIn:
        return 'DINE-IN';
      case OrderType.takeOut:
        return 'TAKE-OUT';
    }
  }
}

enum PaymentMethod { cash, card, gcash, maya }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.card:
        return 'CARD';
      case PaymentMethod.gcash:
        return 'GCASH';
      case PaymentMethod.maya:
        return 'MAYA';
    }
  }
}
