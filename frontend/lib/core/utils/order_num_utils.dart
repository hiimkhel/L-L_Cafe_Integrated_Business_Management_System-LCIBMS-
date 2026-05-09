class OrderNumberUtils {
  static String formatOrderNumber(int id, String source) {
    // We use the SOURCE (POS vs ONLINE) to determine the prefix
    // rather than the specific order type (Dine-in/Take-out)
    String prefix;
    
    switch (source.toUpperCase()) {
      case 'ONLINE':
      case 'APP':
        prefix = 'ONL';
        break;
      case 'POS':
      default:
        prefix = 'WALK';
        break;
    }
    
    // Returns format like: WALK-00091 or ONL-00092
    return '$prefix-${id.toString().padLeft(5, '0')}';
  }
}