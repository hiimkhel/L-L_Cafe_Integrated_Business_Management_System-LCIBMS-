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
    String? startDate,
    String? endDate,
  ) async {

    String url = '$baseUrl/revenue';

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

  Future<Map<String, dynamic>> getOrdersReport(
    String? startDate,
    String? endDate,
  ) async {

    String url = '$baseUrl/orders';

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

  Future<Map<String, dynamic>> getSalesDistributionReport(
    String? startDate,
    String? endDate,
  ) async {

    String url = '$baseUrl/sales';

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

Future<List<dynamic>> getSalesSummaryReport(
    String range,
  ) async {

    final uri = Uri.parse(
      '$baseUrl/chart',
    ).replace(
      queryParameters: {
        'range': range,
      },
    );

    final response = await http.get(uri);

    final data = jsonDecode(response.body);

    return data['data'];
  }
}