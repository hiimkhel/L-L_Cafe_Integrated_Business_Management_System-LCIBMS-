import 'package:flutter/material.dart';

class AdminOrder {
  final String id;
  final DateTime datetime;
  final String customer;
  final String? customerPhone;
  final int itemCount;
  final String entryType;
  final double total;
  final List<OrderLineItem> items;
  final OrderStatus status;
  final String? note;

  const AdminOrder({
    required this.id,
    required this.datetime,
    required this.customer,
    this.customerPhone,
    required this.itemCount,
    required this.entryType,
    required this.total,
    this.items = const [],
    this.status = OrderStatus.pending,
    this.note,
  });

factory AdminOrder.fromJson(Map<String, dynamic> json) {
  return AdminOrder(
    id: json['id'].toString(),

    datetime: DateTime.parse(json['created_at']),

    customer: json['customer_name'] ?? '',

    customerPhone: json['customer_phone'], // only if backend has it

    itemCount: json['item_count'] ?? 0,

    entryType: json['entry_type'] ?? 'WALK-IN',

    total: double.parse(json['total'].toString()),

    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderLineItem.fromJson(e))
        .toList(),

    status: _parseStatus(json['status'] ?? ''),

    note: json['note'],
  );
}


  AdminOrder copyWith({OrderStatus? status}) => AdminOrder(
        id: id, datetime: datetime, customer: customer,
        customerPhone: customerPhone, itemCount: itemCount,
        entryType: entryType, total: total, items: items,
        status: status ?? this.status, note: note,
      );
}

class OrderLineItem {
  final String name;
  final int qty;
  final double unitPrice;

  const OrderLineItem({required this.name, required this.qty, required this.unitPrice});
  double get subtotal => qty * unitPrice;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        name: json['name'] as String,
        qty: (json['qty'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

enum OrderStatus { pending, preparing, outForDelivery, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:        return 'PENDING';
      case OrderStatus.preparing:      return 'PREPARING';
      case OrderStatus.outForDelivery: return 'OUT FOR DELIVERY';
      case OrderStatus.completed:      return 'COMPLETED';
      case OrderStatus.cancelled:      return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:        return const Color(0xFFE6A817);
      case OrderStatus.preparing:      return const Color(0xFF2196F3);
      case OrderStatus.outForDelivery: return const Color(0xFF9C27B0);
      case OrderStatus.completed:      return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:      return const Color(0xFFF44336);
    }
  }

  Color get bg {
    switch (this) {
      case OrderStatus.pending:        return const Color(0xFFFFF8E1);
      case OrderStatus.preparing:      return const Color(0xFFE3F2FD);
      case OrderStatus.outForDelivery: return const Color(0xFFF3E5F5);
      case OrderStatus.completed:      return const Color(0xFFE8F5E9);
      case OrderStatus.cancelled:      return const Color(0xFFFFEBEE);
    }
  }
}
OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'preparing':
      return OrderStatus.preparing;
    case 'out_for_delivery':
      return OrderStatus.outForDelivery;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'rejected':
      return OrderStatus.cancelled; 
    default:
      return OrderStatus.pending;
  }
}