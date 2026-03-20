import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  //-------------------------Palette----------------------------------------------------------------
  static const _primary = Color(0xFFEFE2C9);
  static const _secondary = Color(0xFF758C6D);
  static const _tertiary = Color(0xFFa98258);
  static const _bg = Color(0xFFFFFFFF);

  static const _sidebarBg = Color(0xFFE8D5B0);
  static const _panelBg = Color(0xFFF0E4C4);
  static const _cardBg = Color(0xFFF8F0DC);
  static const _brown = Color(0xFF7A5C3A);
  static const _darkBrown = Color(0xFF3D2B1A);
  static const _green = Color(0xFF4A7C59);
  static const _amber = Color(0xFFD4A843);
  static const _red = Color(0xFFCC4444);
  static const _border = Color(0xFFCCB88A);
  static const _textMain = Color(0xFF3A2A1A);
  static const _textSub = Color(0xFF9A8A72);
  static const _selectedCat = Color(0xFFDDC89A);
  /*

  //-------------------------State----------------------------------------------------------------
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

  void _onSelectCategory(String cat) {
    setState((){
      selectedCategory = cat;
      selectedItemName = null;
      _nameCtrl.clear();
      _priceCtrl.clear();
      _descCtrl.clear();
    });
  }

*/
  //-------------------------Build----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                //_buildFilterRow(),
                //Expanded(child: _buildThreePanels()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------SideBar-------------------------------------------------------------
  Widget _buildSidebar() {
    final navItems = [
      (Icons.dashboard_rounded, "DASHBOARD"),
      (Icons.dashboard_rounded, "ORDERS"),
      (Icons.dashboard_rounded, "MENU\nMANAGEMENT"),
      (Icons.dashboard_rounded, "REPORTS"),
      (Icons.dashboard_rounded, "CUSTOMERS"),
      (Icons.dashboard_rounded, "REVIEWS"),
      (Icons.dashboard_rounded, "CMS"),
    ];

    return Container(
      width: 148,
      color: _primary,
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 75),
          ...navItems.map(
            (e) => _navTile(
              e.$1,
              e.$2,
              selected: e.$2.contains("MENU\nMANAGEMENT"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String label, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? _secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _bg : _tertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _tertiary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.bold,
                  height: 1.50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //-------------------------BuildTopBar-------------------------------------------------------------
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: _secondary,
        border: Border(bottom: BorderSide(color: _primary.withOpacity(.5))),
      ),
      child: Row(
        children: [
          Text(
            "MENU MANAGEMENT",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _darkBrown,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------FilterRow-------------------------------------------------------------

  //-------------------------ThreePanels-------------------------------------------------------------
}
