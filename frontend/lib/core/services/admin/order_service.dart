import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/admin_order.dart';

class OrderService {
  static const String baseUrl =
      "http://localhost:3006/api/admin/orders";

  Future<List<AdminOrder>> getOrders({
    String? startDate,
    String? endDate,
    String? status,
    String? search,
  }) async {
    String url = baseUrl;

    final queryParams = <String, String>{};

    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate;
      queryParams['endDate'] = endDate;
    }

    if (status != null && status != 'ALL') {
      queryParams['status'] = status;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(Uri.parse(url));
    
    final data = jsonDecode(response.body);

    return (data['data'] as List)
        .map((e) => AdminOrder.fromJson(e))
        .toList();
  }
}