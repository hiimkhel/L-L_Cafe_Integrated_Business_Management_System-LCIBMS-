import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsService {
  static const String baseUrl = "http://localhost:3006/api/admin/reports";

   Future<List<dynamic>> getTopCustomers(
    String? startDate,
    String? endDate,
  ) async {
    String url = '$baseUrl/customer';

    if (startDate != null && endDate != null) {
      url +=
          '?startDate=$startDate&endDate=$endDate';
    }

    final response = await http.get(
      Uri.parse(url),
    );

    final data = jsonDecode(response.body);

    return data['data'];
  }


  Future<List<dynamic>> getTopMenuItems(
    String? startDate,
    String? endDate,
  ) async {

    String url = '$baseUrl/menu';

    if (startDate != null && endDate != null) {
      url +=
          '?startDate=$startDate&endDate=$endDate';
    }

    final response = await http.get(
      Uri.parse(url),
    );

    final data = jsonDecode(response.body);

    return data['data'];
  }


  Future<Map<String, dynamic>> getRevenueReport(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/revenue?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<Map<String, dynamic>> getOrdersReport(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/orders?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<Map<String, dynamic>> getSalesDistributionReport(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/sales?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);
    return data['data'];
  }

    Future<List<dynamic>> getSalesSummaryReport(
    String startDate,
    String endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/chart?startDate=$startDate&endDate=$endDate',
      ),
    );

    final data = jsonDecode(response.body);
    return data['data'];
  }
}