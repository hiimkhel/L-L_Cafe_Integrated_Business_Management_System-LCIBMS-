import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
//import 'package:frontend/core/constants/menu_item.dart';
import 'package:frontend/core/constants/menu_data.dart';
//import 'package:frontend/core/constants/menu_controller.dart';

class MenuManagementScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const MenuManagementScreen({super.key, this.activeIndex = 2, required this.onLogout});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  //--------------------------------------------------State---------------------------------------------------------------------

  String selectedCategory = 'Foods';
  String? selectedItemName = 'Chicken Burger';
  bool isAvailable = true;

  final List<String> categories = MenuData.categories;
  final Map<String, List<Map<String, String>>> itemsByCategory =
      MenuData.itemsByCategory;

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final item = _selectedItemData;
    _nameCtrl = TextEditingController(text: item?['name'] ?? '');
    _priceCtrl = TextEditingController(text: item?['price'] ?? '');
    _descCtrl = TextEditingController(text: item?['desc'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _currentItems =>
      itemsByCategory[selectedCategory] ?? [];

  Map<String, String>? get _selectedItemData {
    if (selectedItemName == null) return null;
    try {
      return _currentItems.firstWhere((i) => i['name'] == selectedItemName);
    } catch (_) {
      return null;
    }
  }

  void _onSelectItem(Map<String, String> item) {
    setState(() {
      selectedItemName = item['name'];
      _nameCtrl.text = item['name'] ?? '';
      _priceCtrl.text = item['price'] ?? '';
      _descCtrl.text = item['desc'] ?? '';
    });
  }

  void _onSelectCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      selectedItemName = null;
      _nameCtrl.clear();
      _priceCtrl.clear();
      _descCtrl.clear();
    });
  }

  //-----------------------------------------------------------Build--------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: widget.activeIndex,  onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminHeader(title: "MENU MANAGEMENT",  onLogout: widget.onLogout),
                _buildFilterRow(),
                Expanded(child: _buildThreePanels()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------FilterRow------------------------------------------------------------------------

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,

              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.8),

                  offset: Offset(0, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  "ALL ITEMS",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 210,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(1.0),
                    offset: Offset(0, 4),
                    blurRadius: 9,
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: TextStyle(fontSize: 15, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: "SEARCH ITEM...",
                  hintStyle: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    letterSpacing: .8,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.primary, width: .9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------------------------------------------ThreePanels-----------------------------------------------------------------------------

  Widget _buildThreePanels() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 5, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 190, child: _buildCategoryPanel()),
            VerticalDivider(width: 1, color: AppColors.primary),
            SizedBox(width: 230, child: _buildItemsPanel()),
            VerticalDivider(width: 1, color: AppColors.primary),
            Expanded(child: _buildDetailsPanel()),
          ],
        ),
      ),
    );
  }

  Widget _panelHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _greenBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _panelHeader('Category'),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 32,
            width: 165,
            child: _greenBtn('+ Add Category', () {}),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            children: categories.map(_buildCategoryTitle).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTitle(String cat) {
    final selected = selectedCategory == cat;
    return GestureDetector(
      onTap: () => _onSelectCategory(cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.background : Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          cat,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panelHeader('Items'),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: SizedBox(
            height: 34,
            child: TextField(
              style: TextStyle(fontSize: 12, color: AppColors.primary),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.primary, fontSize: 12),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 16,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: _greenBtn('+  Add Item', () {}),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            children: _currentItems.map(_buildItemTile).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(Map<String, String> item) {
    final selected = selectedItemName == item['name'];
    return GestureDetector(
      onTap: () => _onSelectItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.background : Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['desc'] ?? '',
                    style: TextStyle(color: AppColors.tertiary, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item['price'] ?? '',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel() {
    if (selectedItemName == null || _selectedItemData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('Details'),
          Expanded(
            child: Center(
              child: Text(
                'Select an item to view details',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panelHeader('Details'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.background,
                      child: Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedItemName!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Item Name',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Transform.scale(
                            scale: .7,
                            child: Switch(
                              value: isAvailable,
                              onChanged: (v) => setState(() => isAvailable = v),
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: AppColors.background,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _fieldLabel('Name'),
                _inputField(_nameCtrl, 'Item Name'),
                const SizedBox(height: 14),
                _fieldLabel('Price'),
                _inputField(
                  _priceCtrl,
                  'Item price',
                  suffix: const Icon(
                    Icons.unfold_more,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel('Description'),
                _inputField(_descCtrl, 'Item Description...', maxLines: 4),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Item Photo',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primary,
                        size: 38,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Choose a file or drag & drop it here',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          'Browse file',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.primary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.primary, fontSize: 12),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
      ),
    );
  }
}
