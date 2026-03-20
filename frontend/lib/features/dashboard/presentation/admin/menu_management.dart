import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget{
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {

  //-------------------------Palette------------------------------
  static const _primary = Color(0xFFEFE2C9);
  static const _secondary = Color(0xFF758C6D);
  static const _tertiary = Color(0xFFa98258);
  static const _bg = Color(0xFFFFFFFF);


  //-------------------------State------------------------------
  String selectedCategory = "Foods";
  String? selectedItemName = "Chicken Burger";
  bool isAvailable = true;

  final List<String> categories = [
    "Foods",
    "Party Tray", 
    "Waffles", 
    "Coffee", 
    "Non-Coffee", 
    "Frappe"
  ];

  final Map<String, List<Map<String, String>>> itemsByCategory = {
    "Foods": [
      {"name": "Chicken Burger",  "price": "₱199.00", "desc": "This is a description."},
      {"name": "Cheese Burger",   "price": "₱199.00", "desc": "This is a description."},
      {"name": "Hawaiian Burger", "price": "₱199.00", "desc": "This is a description."},
    ],
    "Party Tray": [
      {"name": "Barkada Platter", "price": "₱599.00", "desc": "Good for 5–6 persons."},
    ],
    "Waffles": [
      {"name": "Classic Waffle", "price": "₱149.00", "desc": "Crispy golden waffle."},
      {"name": "Choco Waffle",   "price": "₱169.00", "desc": "With rich chocolate drizzle."},
    ],
    "Coffee": [
      {"name": "Americano",   "price": "₱99.00",  "desc": "Bold and smooth espresso."},
      {"name": "Cappuccino",  "price": "₱119.00", "desc": "Espresso with steamed milk."},
    ],
    "Non-Coffee": [
      {"name": "Matcha Latte", "price": "₱129.00", "desc": "Premium Japanese matcha."},
    ],
    "Frappe": [
      {"name": "Mocha Frappe",   "price": "₱139.00", "desc": "Chilled mocha bliss."},
      {"name": "Caramel Frappe", "price": "₱139.00", "desc": "Sweet caramel swirls."},
    ],
  };

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final item = _selectedItemData;
    _nameCtrl = TextEditingController(text: item?["name"] ?? "");
    _priceCtrl = TextEditingController(text: item?["price"] ?? "");
    _descCtrl = TextEditingController(text: item?["desc"] ?? "");
  }

  @override
  void dispose(){
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  } 

  List<Map<String, String>> get _currentItems => itemsByCategory[selectedCategory] ?? [];

  Map<String, String>? get _selectedItemdata {
    if (selectedItemName == null) return null;
    try {
      return _currentItems.firstWhere((i) => i["name"] == selectedItemName);
    } catch (_) {
      return null;
    }
  }

  void _onSelectItem(Map<String, String> item){
    setState((){
      selectedItemName = item["name"];
      _nameCtrl.text = item["name"] ?? "";
      _priceCtrl.text = item["price"] ?? "";
      _descCtrl.text = item["desc"] ?? "";
    });
  }

  

  }


