class ApiConfig {

  static const bool isProduction = false;

  static const String localBaseUrl = "http://localhost:3006/api";
  static const String lanBaseUrl = "http://192.168.56.1:3006/api";
  static const String productionBaseUrl =
      "https://lcibms-backend.onrender.com/api";

  static String get baseUrl {
    if (isProduction) return productionBaseUrl;

    // default dev mode
    return lanBaseUrl;
  }
}