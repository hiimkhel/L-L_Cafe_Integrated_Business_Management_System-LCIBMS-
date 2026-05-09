class OrderNumberUtils {
  static String formatOrderNumber(int id, String type) {
    // Logic to determine prefix
    String prefix;
    switch (type.toUpperCase()) {
      case 'ONLINE':
        prefix = 'ONL';
        break;
      case 'TAKE OUT':
        prefix = 'TO';
        break;
      case 'DINE IN':
      default:
        prefix = 'WALK';
        break;
    }
    
    // Returns format like: WALK-00123
    return '$prefix-${id.toString().padLeft(5, '0')}';
  }
}