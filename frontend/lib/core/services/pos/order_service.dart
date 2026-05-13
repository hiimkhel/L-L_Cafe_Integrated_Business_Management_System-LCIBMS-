import 'dart:convert';
import 'package:frontend/core/models/order_request.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl = "http://localhost:3006/api";

  // From ordersRoutes.js rather than posRoutes.js
  Future<bool> createOrder(OrderRequest order) async {
    final response = await http.post(
      Uri.parse("$baseUrl/orders/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 200) {
      print(order);
      print(response);
      return true;
    } else {
      print(response.body);
      return false;
    }
  }

  // POS Access API Endpoints
  Future<List<dynamic>> getOrdersByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pos/orders?status=$status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      print("Service Error: $e");
      return [];
    }
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/pos/orders/$id/status'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Update Error: $e");
      return false;
    }
  }

  // Fetch all online orders
  Future<List<Map<String, dynamic>>> fetchOnlineOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/pos/orders/online'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders');
    }

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      data['data'],
    ).map((o) => _mapOrder(o)).toList();
  }

  Map<String, dynamic> _mapOrder(Map<String, dynamic> o) {
    print('payment_proof_url: ${o['payment_proof_url']}');
    String mapStatus(String status) {
      switch (status) {
        case 'pending':
          return 'PENDING';
        case 'preparing':
        case 'confirmed':
        case 'ready':
        case 'out_for_delivery':
        case 'completed':
          return 'ACCEPTED';
        case 'rejected':
        case 'cancelled':
          return 'REJECTED';
        default:
          return 'PENDING';
      }
    }

    return {
      'id': o['order_number'] ?? 'UNKNOWN',
      'db_id': o['id'],
      'time': '',
      'status': mapStatus(o['status']),
      'customer': o['customer_name'] ?? 'Guest',
      'phone': o['customer_phone'] ?? 'N/A',
      'delivery_address': o['delivery_address'] ?? 'No address yet',
      'items':
          (o['items'] as List)
              .map(
                (i) => {
                  'name': i['name'],
                  'qty': i['quantity'],
                  'price': double.parse(i['unit_price'].toString()),
                },
              )
              .toList(),
      'specialInstructions': o['notes'],
      'payment_method': (o['payment_method'] ?? '').toLowerCase(),
      'payment':
          '${(o['payment_method'] ?? 'N/A').toUpperCase()} - ${o['payment_status'].toUpperCase()}',
      'payment_proof_url': o['payment_proof_url'],
      'tax': 0.12,
      'total': double.parse(o['total'].toString()),
    };
  }

  Future<bool> acceptOrder(int id) async {
    return await updateOrderStatus(id, 'preparing');
  }

  Future<bool> rejectOrder(int id) async {
    return await updateOrderStatus(id, 'rejected');
  }

  Future<int> getPreparingCount() async {
    final response = await http.get(
      Uri.parse("$baseUrl/pos/orders/preparing-count"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'];
    } else {
      throw Exception('Failed to fetch count');
    }
  }

  Future<int> getPendingCount() async {
    final response = await http.get(
      Uri.parse("$baseUrl/pos/orders/online-pending-count"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'];
    } else {
      throw Exception('Failed to fetch count');
    }
  }


  Future<Map<String, dynamic>> fetchOrderHistory({
    String search = '',
    String dateFilter = 'all', // today | yesterday | last7days | all
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/pos/orders/history'
        '?search=${Uri.encodeComponent(search)}'
        '&dateFilter=$dateFilter'
        '&page=$page'
        '&limit=$limit',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch order history');
      }

      final data = jsonDecode(response.body);

      final List<Map<String, dynamic>> orders =
          List<Map<String, dynamic>>.from(
            data['data'],
          ).map((order) => _mapOrderHistory(order)).toList();

      return {
        'orders': orders,
        'pagination': data['pagination'],
      };
    } catch (e) {
      print('Order History Error: $e');
      return {
        'orders': <Map<String, dynamic>>[],
        'pagination': {
          'currentPage': 1,
          'pageSize': limit,
          'totalRecords': 0,
          'totalPages': 0,
        },
      };
    }
  }

  // Maps backend response to UI-friendly structure
  Map<String, dynamic> _mapOrderHistory(Map<String, dynamic> o) {
    return {
      // Time column
      'time': o['created_at'],

      // Customer Name column
      'customer_name': o['customer_name'] ?? 'Walk-in Customer',

      // Order ID column
      'order_id': o['order_number'] ?? 'N/A',

      // Item Count column
      'item_count': int.tryParse(o['item_count'].toString()) ?? 0,

      // Payment Type column
      'payment_type':
          (o['payment_method'] ?? 'N/A').toString().toUpperCase(),

      // Total Value column
      'total':
          double.tryParse(o['total'].toString()) ?? 0.0,

      // Full order data for "View Receipt"
      'full_order_data': _decodeFullOrderData(o['full_order_data']),
    };
  }

  // Decode JSON_OBJECT result from MySQL
  Map<String, dynamic> _decodeFullOrderData(dynamic fullOrderData) {
    if (fullOrderData == null) {
      return {};
    }

    // If backend returns JSON string
    if (fullOrderData is String) {
      return jsonDecode(fullOrderData);
    }

    // If backend already returns Map
    if (fullOrderData is Map<String, dynamic>) {
      return fullOrderData;
    }

    // Convert generic map
    if (fullOrderData is Map) {
      return Map<String, dynamic>.from(fullOrderData);
    }

    return {};
  }
}
