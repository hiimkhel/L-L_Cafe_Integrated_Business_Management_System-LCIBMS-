class ApiConfig {

  static const bool isProduction = false;

  static const String localBaseUrl = "http://localhost:3006/api";
  static const String lanBaseUrl = "http://10.179.3.122:3006/api";
  static const String productionBaseUrl =
      "https://lcibms-backend.onrender.com/api";

  static String get baseUrl {
    if (isProduction) return productionBaseUrl;

    // default dev mode
    return localBaseUrl;
  }

  static String get imageBaseUrl {
    if (isProduction) {
      return "https://lcibms-backend.onrender.com/uploads/menu-items";
    }
    return "http://10.179.3.122:3006/uploads/menu-items";
  }

  static String get imageBaseUrl {
    if (isProduction) {
      return "https://lcibms-backend.onrender.com/uploads/menu-items";
    }
    return "http://10.179.3.122:3006/uploads/menu-items";
  }
}