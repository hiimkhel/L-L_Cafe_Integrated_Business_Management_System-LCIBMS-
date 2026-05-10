class OrderRequest {
  final String source;
  final int? userId;
  final String orderType;

  final double subtotal;
  final double deliveryFee;
  final String? deliveryAddress;
  final double total;

  final String paymentMethod;
  final String paymentStatus;

  final String? customerName;
  final String? customerPhone;

  final List<Map<String, dynamic>> items;

  final String? notes;
  final String? paymentProofUrl;
  OrderRequest({
    required this.source,
    this.userId,
    required this.orderType,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryAddress,
    this.customerName,
    this.customerPhone,
    required this.items,
    this.notes,
    this.paymentProofUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "source": source.toLowerCase(),
      "user_id": userId,
      "order_type": orderType.toLowerCase().replaceAll(' ', '-'),
      "subtotal": subtotal,
      "delivery_fee": deliveryFee,
      "delivery_address": deliveryAddress,
      "total": total,
      "payment_method": _mapPaymentMethod(paymentMethod),
      "payment_status": paymentStatus.toLowerCase(),
      "customer_name": customerName,
      "customer_phone": customerPhone,
      "items": items,
      "notes": notes,
      'payment_proof_url': paymentProofUrl,
    };
  }
}

String _mapPaymentMethod(String method) {
  String m = method.toLowerCase();
  if (m == 'gcash' || m == 'maya' || m == 'e-wallet') return 'e-wallet';
  return m; // returns 'cash' or 'card'
}
