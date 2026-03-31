// menu_controller.dart
import 'package:flutter/material.dart';
import '../constants/menu_data.dart';

class MenuController extends ChangeNotifier {
  String selectedCategory = 'Foods';
  Map<String, String>? selectedItem;
  bool isAvailable = true;

  final Map<String, List<Map<String, String>>> itemsByCategory =
      MenuData.itemsByCategory;

  final nameCtrl  = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl  = TextEditingController();

  MenuController() {
    final first = currentItems.isNotEmpty ? currentItems.first : null;
    if (first != null) _loadItemIntoFields(first);
  }

  @override  
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get currentItems =>
      itemsByCategory[selectedCategory] ?? [];

  void selectCategory(String cat) {
    selectedCategory = cat;
    selectedItem = null;
    nameCtrl.clear();
    priceCtrl.clear();
    descCtrl.clear();
    notifyListeners();
  }

  void selectItem(Map<String, String> item) {  
    selectedItem = item;
    isAvailable  = item['isAvailable'] == 'true';
    _loadItemIntoFields(item);
    notifyListeners();
  }

  void toggleAvailable(bool value) {
    isAvailable = value;
    notifyListeners();
  }

  void _loadItemIntoFields(Map<String, String> item) {  
    nameCtrl.text  = item['name']  ?? '';
    priceCtrl.text = item['price'] ?? '';
    descCtrl.text  = item['desc']  ?? '';
  }
}