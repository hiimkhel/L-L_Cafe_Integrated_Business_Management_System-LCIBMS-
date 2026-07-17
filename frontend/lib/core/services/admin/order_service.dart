import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/admin_order.dart';
import 'package:frontend/core/constants/api_configs.dart';

class OrderService {

  final String baseUrl = ApiConfig.baseUrl;


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
      url += '/admin/orders?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(Uri.parse(url));
    
    final data = jsonDecode(response.body);

    return (data['data'] as List)
        .map((e) => AdminOrder.fromJson(e))
        .toList();
  }


   Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint("GET ORDER RESPONSE:");
        debugPrint(data.toString());

        return Map<String, dynamic>.from(data["order"]);
      }

      debugPrint("Get Order Error: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Get Order Exception: $e");
      return null;
    }
  }
}