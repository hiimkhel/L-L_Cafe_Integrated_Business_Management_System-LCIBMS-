import 'dart:io';
import 'dart:typed_data'; // REQUIRED FOR Uint8List
import 'package:flutter/foundation.dart'; // REQUIRED FOR kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // REQUIRED FOR FilePicker
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/services/admin/menu_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const _kRadius = 12.0;
const _kBorder = Color(0xFFE8DDD0);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MenuManagementScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;

  const MenuManagementScreen({
    super.key,
    this.activeIndex = 2,
    required this.onLogout,
  });

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // ── State ────────────────────────────────────────────────────────────────
  String _globalSearch = '';
  String _itemSearch = '';
  bool isAvailable = true;
  bool isLoadingItem = false;

  String? selectedItemName;
  dynamic selectedItem;
  List<dynamic> categories = [];
  List<dynamic> items = [];
  List<dynamic> _filteredItems = [];
  int? selectedCategoryId;

  // Image / file
  String? _pickedFileName;
  Uint8List? _pickedFileBytes; 
  String? _pickedFilePath; 

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _globalSearchCtrl;
  late final TextEditingController _itemSearchCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _globalSearchCtrl = TextEditingController();
    _itemSearchCtrl = TextEditingController();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _globalSearchCtrl.dispose();
    _itemSearchCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ─────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    try {
      final data = await MenuService.fetchCategories();
      setState(() {
        categories = data;
        if (categories.isNotEmpty) {
          selectedCategoryId = categories[0]['id'];
        }
      });
      if (selectedCategoryId != null) _loadItems(selectedCategoryId!);
    } catch (e) {
      _showError('Failed to load categories');
    }
  }

  Future<void> _loadItems(int categoryId) async {
    try {
      final data = await MenuService.fetchMenuItems(categoryId);
      setState(() {
        items = data;
        _filteredItems = _applyItemSearch(data, _itemSearch);
      });
    } catch (e) {
      _showError('Failed to load items');
    }
  }

  List<dynamic> _applyItemSearch(List<dynamic> src, String q) {
    if (q.trim().isEmpty) return List.from(src);
    final lower = q.toLowerCase();
    return src
        .where((i) =>
            (i['name'] ?? '').toString().toLowerCase().contains(lower))
        .toList();
  }

  void _onItemSearchChanged(String q) {
    setState(() {
      _itemSearch = q;
      _filteredItems = _applyItemSearch(items, q);
    });
  }

  void _onSelectCategory(dynamic category) {
    setState(() {
      selectedCategoryId = category['id'];
      selectedItem = null;
      selectedItemName = null;
      _itemSearch = '';
      _itemSearchCtrl.clear();
    });
    _loadItems(category['id']);
  }

  void _onSelectItem(dynamic item) async {
    setState(() => isLoadingItem = true);
    try {
      final fresh = await MenuService.fetchMenuItemById(item['id']);
      setState(() {
        selectedItem = fresh;
        selectedItemName = fresh['name'];
        _nameCtrl.text = fresh['name'] ?? '';
        _priceCtrl.text = fresh['price'].toString();
        _descCtrl.text = fresh['description'] ?? '';
        isAvailable = fresh['is_available'] == 1;
        _pickedFileName = null;
        _pickedFileBytes = null;
        _pickedFilePath = null;
      });
    } catch (_) {
      _showError('Failed to load item details');
    } finally {
      setState(() => isLoadingItem = false);
    }
  }

  Future<void> _saveItem() async {
    if (selectedItem == null) return;
    try {
      await MenuService.updateMenuItem(selectedItem['id'], {
        'name': _nameCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'description': _descCtrl.text.trim(),
        'is_available': isAvailable ? 1 : 0,
      });
      _loadItems(selectedCategoryId!);
      _showSuccess('Item updated successfully');
    } catch (e) {
      _showError('Failed to save changes');
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    if (item == null) return;
    try {
      await MenuService.deleteMenuItem(item['id']);
      setState(() {
        items.removeWhere((i) => i['id'] == item['id']);
        _filteredItems = _applyItemSearch(items, _itemSearch);
        if (selectedItem?['id'] == item['id']) {
          selectedItem = null;
          selectedItemName = null;
        }
      });
      _showSuccess('Item deleted');
    } catch (e) {
      _showError('Delete failed');
    }
  }

  // >>> THIS IS LINE 196: It requires MenuService.deleteCategory to exist <<<
  Future<void> _deleteCategory(dynamic category) async {
    if (category == null) return;
    try {
      await MenuService.deleteCategory(category['id']);
      setState(() {
        categories.removeWhere((c) => c['id'] == category['id']);
        if (selectedCategoryId == category['id']) {
          selectedItem = null;
          selectedItemName = null;
          items = [];
          _filteredItems = [];
          if (categories.isNotEmpty) {
            selectedCategoryId = categories[0]['id'];
            _loadItems(selectedCategoryId!);
          } else {
            selectedCategoryId = null;
          }
        }
      });
      _showSuccess('Category deleted');
    } catch (e) {
      _showError('Failed to delete category');
    }
  }

  // >>> THIS IS LINE 223: It requires file_picker to be properly loaded <<<
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
  type: FileType.image,
  withData: kIsWeb,
);

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() {
        _pickedFileName = file.name;
        if (kIsWeb) {
          _pickedFileBytes = file.bytes;
          _pickedFilePath = null;
        } else {
          _pickedFilePath = file.path;
          _pickedFileBytes = null;
        }
      });
    } catch (e) {
      debugPrint("Picker Error: $e");
    }
  }

  // ── Feedback ──────────────────────────────────────────────────────────────

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(title: 'MENU MANAGEMENT', onLogout: widget.onLogout),
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _buildPanels(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              controller: _globalSearchCtrl,
              onChanged: (v) => setState(() => _globalSearch = v),
              style: TextStyle(fontSize: 13, color: AppColors.primary),
              decoration: _searchDeco('Search all items...'),
            ),
          ),
          const Spacer(),
          _OutlineBtn(
            label: '+ Add Category',
            icon: Icons.category_outlined,
            onTap: () => _showAddDialog(type: 'category'),
          ),
          const SizedBox(width: 10),
          _FilledBtn(
            label: '+ Add Item',
            icon: Icons.add_circle_outline,
            onTap: () => _showAddDialog(type: 'item'),
          ),
        ],
      ),
    );
  }

  Widget _buildPanels() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 200, child: _buildCategoryPanel()),
          _divider(),
          SizedBox(width: 250, child: _buildItemsPanel()),
          _divider(),
          Expanded(child: _buildDetailsPanel()),
        ],
      ),
    );
  }

  Widget _divider() => VerticalDivider(width: 1, thickness: 1, color: _kBorder);

  Widget _buildCategoryPanel() {
    return Column(children: [
      const _PanelHeader(title: 'CATEGORIES'),
      Expanded(
        child: categories.isEmpty
            ? _emptyHint('No categories yet')
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) => _buildCategoryTile(categories[i]),
              ),
      ),
    ]);
  }

  Widget _buildCategoryTile(dynamic cat) {
    final selected = selectedCategoryId == cat['id'];
    return GestureDetector(
      onTap: () => _onSelectCategory(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.only(left: 14, right: 6, top: 11, bottom: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cat['name'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.7),
              ),
            ),
          ),
          Tooltip(
            message: 'Delete category',
            child: GestureDetector(
              onTap: () => _confirmDeleteCategory(cat),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildItemsPanel() {
    return Column(children: [
      const _PanelHeader(title: 'ITEMS'),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: SizedBox(
          height: 36,
          child: TextField(
            controller: _itemSearchCtrl,
            onChanged: _onItemSearchChanged,
            style: TextStyle(fontSize: 12, color: AppColors.primary),
            decoration: _searchDeco('Search items...'),
          ),
        ),
      ),
      Expanded(
        child: _filteredItems.isEmpty
            ? _emptyHint(_itemSearch.isNotEmpty
                ? 'No results for "$_itemSearch"'
                : 'No items in this category')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) => _buildItemTile(_filteredItems[i]),
              ),
      ),
    ]);
  }

  Widget _buildItemTile(dynamic item) {
    final selected = selectedItemName == item['name'];
    final available = item['is_available'] == 1;

    return GestureDetector(
      onTap: () => _onSelectItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                item['name'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₱${item['price']}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
            ]),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: available ? const Color(0xFF4CAF50) : Colors.redAccent,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildDetailsPanel() {
    if (selectedItemName == null) {
      return Column(children: [
        const _PanelHeader(title: 'DETAILS'),
        Expanded(child: _emptyHint('Select an item to view and edit details')),
      ]);
    }

    if (isLoadingItem) {
      return Column(children: [
        const _PanelHeader(title: 'DETAILS'),
        const Expanded(child: Center(child: CircularProgressIndicator())),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _PanelHeader(title: 'DETAILS'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  selectedItemName!,
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                Text(
                  categories.firstWhere((c) => c['id'] == selectedCategoryId,
                          orElse: () => {'name': ''})['name'] ??
                      '',
                  style: TextStyle(fontSize: 11, color: AppColors.primary.withOpacity(0.5)),
                ),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? const Color(0xFF4CAF50) : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 36,
                    height: 20,
                    child: Switch(
                      value: isAvailable,
                      onChanged: (v) => setState(() => isAvailable = v),
                      activeThumbColor: const Color(0xFF4CAF50),
                      inactiveThumbColor: Colors.redAccent,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ]),
              ),
            ]),

            const SizedBox(height: 24),
            const Divider(color: _kBorder, height: 1),
            const SizedBox(height: 24),

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _FieldLabel('Item Name'),
                const SizedBox(height: 6),
                _StyledField(ctrl: _nameCtrl, hint: 'e.g. Chicken Burger'),
              ])),
              const SizedBox(width: 16),
              SizedBox(
                  width: 140,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const _FieldLabel('Price (₱)'),
                    const SizedBox(height: 6),
                    _StyledField(
                      ctrl: _priceCtrl,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ])),
            ]),

            const SizedBox(height: 16),
            const _FieldLabel('Description'),
            const SizedBox(height: 6),
            _StyledField(ctrl: _descCtrl, hint: 'Describe the item...', maxLines: 3),

            const SizedBox(height: 20),
            const _FieldLabel('Item Photo'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _pickedFileName != null
                        ? AppColors.primary.withOpacity(0.6)
                        : _kBorder,
                  ),
                ),
                child: _pickedFileName != null
                    ? _buildFilePreview()
                    : _buildUploadPlaceholder(),
              ),
            ),

            const SizedBox(height: 28),
            Row(children: [
              _FilledBtn(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                onTap: _saveItem,
              ),
              const SizedBox(width: 10),
              _OutlineBtn(
                label: 'Delete Item',
                icon: Icons.delete_outline,
                onTap: () => _confirmDelete(selectedItem),
                danger: true,
              ),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildFilePreview() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        if (!kIsWeb && _pickedFilePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_pickedFilePath!),
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image_outlined, color: AppColors.primary, size: 30),
          ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _pickedFileName!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickFile,
              child: Text('Change file',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiary,
                      decoration: TextDecoration.underline)),
            ),
          ],
        )),
        GestureDetector(
          onTap: () => setState(() {
            _pickedFileName = null;
            _pickedFileBytes = null;
            _pickedFilePath = null;
          }),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.close_rounded,
                size: 16, color: AppColors.primary.withOpacity(0.5)),
          ),
        ),
      ]),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.cloud_upload_outlined,
          color: AppColors.primary.withOpacity(0.4), size: 32),
      const SizedBox(height: 6),
      Text(
        'Click to choose a file or drag & drop',
        style: TextStyle(fontSize: 11, color: AppColors.primary.withOpacity(0.5)),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _kBorder),
        ),
        child: Text('Browse file',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
    ]);
  }

  void _showAddDialog({required String type}) {
    final isItem = type == 'item';
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(isItem ? Icons.fastfood_outlined : Icons.category_outlined,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isItem ? 'Add New Item' : 'Add Category',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration:
                          BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                const Divider(color: _kBorder, height: 1),
                const SizedBox(height: 20),
                _FieldLabel(isItem ? 'Item Name' : 'Category Name'),
                const SizedBox(height: 6),
                _StyledField(
                    ctrl: nameCtrl, hint: isItem ? 'e.g. Chicken Burger' : 'e.g. Waffles'),
                if (isItem) ...[
                  const SizedBox(height: 14),
                  const _FieldLabel('Price (₱)'),
                  const SizedBox(height: 6),
                  _StyledField(
                    ctrl: priceCtrl,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Description'),
                  const SizedBox(height: 6),
                  _StyledField(ctrl: descCtrl, hint: 'Describe the item...', maxLines: 3),
                ],
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _OutlineBtn(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
                  const SizedBox(width: 10),
                  _FilledBtn(
                    label: 'Save',
                    icon: Icons.check_rounded,
                    onTap: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      try {
                        if (isItem) {
                          await MenuService.addItem({
                            'name': name,
                            'price': double.tryParse(priceCtrl.text) ?? 0,
                            'description': descCtrl.text.trim(),
                            'category_id': selectedCategoryId,
                          });
                          _loadItems(selectedCategoryId!);
                        } else {
                          await MenuService.addCategory(name);
                          _loadCategories();
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSuccess(isItem ? 'Item added' : 'Category added');
                      } catch (e) {
                        _showError('Failed to save');
                      }
                    },
                  ),
                ]),
              ]),
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    if (item == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(height: 14),
            Text('Delete Item',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to permanently delete "${item['name']}"?\nThis cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: AppColors.primary.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _OutlineBtn(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  await _deleteItem(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Delete Permanently',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _confirmDeleteCategory(dynamic category) {
    if (category == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.category_outlined, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(height: 14),
            Text('Delete Category',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete the "${category['name']}" category?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: AppColors.primary.withOpacity(0.7)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All items inside this category may also be removed. This action cannot be undone.',
                    style: TextStyle(fontSize: 11, height: 1.6, color: Colors.orange.shade800),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _OutlineBtn(label: 'Cancel', onTap: () => Navigator.pop(ctx)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  await _deleteCategory(category);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Delete Category',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  InputDecoration _searchDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary.withOpacity(0.4)),
        prefixIcon: Icon(Icons.search_rounded,
            size: 16, color: AppColors.primary.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary, width: 1.4)),
      );

  Widget _emptyHint(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.primary.withOpacity(0.35))),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final String title;
  const _PanelHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Text(title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: AppColors.primary,
          )),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary.withOpacity(0.7)));
}

class _StyledField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _StyledField({
    super.key,
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13, color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: AppColors.primary.withOpacity(0.3)),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _FilledBtn({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool danger;

  const _OutlineBtn({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: danger ? Colors.red.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}