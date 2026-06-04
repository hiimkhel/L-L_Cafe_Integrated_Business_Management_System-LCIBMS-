import "package:frontend/core/services/admin/sales_reports_services.dart";
class ReportsRepository {
  final ReportsService api;

  ReportsRepository(this.api);

  Future<List<dynamic>> getTopCustomers(
    String startDate,
    String endDate,
  ) {
    return api.getTopCustomers(startDate, endDate);
  }

  Future<List<dynamic>> getTopMenuItems(
    String startDate,
    String endDate,
  ) {
    return api.getTopMenuItems(startDate, endDate);
  }

  // Future<Map<String, dynamic>> getBusinessPerformance(
  //   String startDate,
  //   String endDate,
  // ) {
  //   return api.getBusinessPerformance(startDate, endDate);
  // }
}