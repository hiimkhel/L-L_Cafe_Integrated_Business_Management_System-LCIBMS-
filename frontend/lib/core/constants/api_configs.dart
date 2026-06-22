class ApiConfig {

  static const bool isProduction = false;

  static const String localBaseUrl = "http://localhost:3006/api";
  static const String lanBaseUrl = "http://192.168.1.89:3006/api";
  static const String productionBaseUrl =
      "https://lcibms-backend.onrender.com/api";

  static String get baseUrl {
    if (isProduction) return productionBaseUrl;

    // default dev mode
    return lanBaseUrl;
  }

  static String get imageBaseUrl {
    if (isProduction) {
      return "https://lcibms-backend.onrender.com/uploads/menu-items";
    }
    return "http://192.168.1.89:3006/uploads/menu-items";
  }
}