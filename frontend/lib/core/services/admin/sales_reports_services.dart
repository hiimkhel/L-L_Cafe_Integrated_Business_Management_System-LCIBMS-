import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsService {
  static const String baseUrl = "http://localhost:3006/api/admin/reports";

   Future<List<dynamic>> getTopCustomers(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/customer?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);
    print(data);
    return data['data'];
  }

  Future<List<dynamic>> getTopMenuItems(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/menu?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);

    return data['data'];
  }
}