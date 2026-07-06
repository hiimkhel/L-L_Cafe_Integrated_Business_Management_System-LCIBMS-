import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/services/admin/menu_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

const _kRadius    = 14.0;
const _kBorder    = Color(0xFFEDE0CC);
const _kGreen     = Color(0xFF4CAF50);
const _kRed       = Color(0xFFFF5252);
const _kPrimary   = Color(0xFF758C6D);
const _kSecondary = Color(0xFFA98258);
const _kBg        = Color(0xFFEFE2C9);
const _kDark      = Color(0xFF2D2A26);

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
  // ── State ─────────────────────────────────────────────────────────────────
  String _itemSearch   = '';
  bool   isAvailable   = true;
  bool   isLoadingItem = false;
  bool   isSaving      = false;
  // ✅ Track whether the user has unsaved edits in the details panel
  bool   _isDirty      = false;

  String?  selectedItemName;
  dynamic  selectedItem;

  List<dynamic> categories     = [];
  List<dynamic> items          = [];
  List<dynamic> _filteredItems = [];
  int?          selectedCategoryId;

  String?    _pickedFileName;
  Uint8List? _pickedFileBytes;
  String?    _pickedFilePath;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _itemSearchCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl       = TextEditingController();
    _priceCtrl      = TextEditingController();
    _descCtrl       = TextEditingController();
    _itemSearchCtrl = TextEditingController();

    // Mark dirty whenever any field changes
    _nameCtrl.addListener(_onFieldChanged);
    _priceCtrl.addListener(_onFieldChanged);
    _descCtrl.addListener(_onFieldChanged);

    _loadCategories();
  }

  void _onFieldChanged() {
    if (selectedItem != null && !_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _itemSearchCtrl.dispose();
    super.dispose();
  }

  String getImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return '';
    }
    return '${MenuService.imageUrl}/$imageName';
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    try {
      final data = await MenuService.fetchCategories();
      setState(() {
        categories = data;
        if (categories.isNotEmpty) selectedCategoryId = categories[0]['id'];
      });
      if (selectedCategoryId != null) _loadItems(selectedCategoryId!);
    } catch (_) { _showError('Failed to load categories'); }
  }

  Future<void> _loadItems(int categoryId) async {
    try {
      final data = await MenuService.fetchMenuItems(categoryId);
      setState(() {
        items          = data;
        _filteredItems = _filter(data, _itemSearch);
      });
    } catch (_) { _showError('Failed to load items'); }
  }

  List<dynamic> _filter(List<dynamic> src, String q) {
    if (q.trim().isEmpty) return List.from(src);
    final lo = q.toLowerCase();
    return src.where((i) =>
        (i['name'] ?? '').toString().toLowerCase().contains(lo)).toList();
  }

  void _onSearchChanged(String q) => setState(() {
    _itemSearch    = q;
    _filteredItems = _filter(items, q);
  });

  void _onSelectCategory(dynamic cat) async {
    // ✅ Guard unsaved changes before switching category
    if (_isDirty) {
      final confirmed = await _confirmDiscard();
      if (!confirmed) return;
    }
    setState(() {
      selectedCategoryId = cat['id'];
      selectedItem       = null;
      selectedItemName   = null;
      _itemSearch        = '';
      _itemSearchCtrl.clear();
      _isDirty           = false;
    });
    _loadItems(cat['id']);
  }

  void _onSelectItem(dynamic item) async {

    if (_isDirty) {
      final confirmed = await _confirmDiscard();
      if (!confirmed) return;
    }

    setState(() => isLoadingItem = true);
    try {
      final fresh = await MenuService.fetchMenuItemById(item['id']);
      setState(() {
        selectedItem     = fresh;
        selectedItemName = fresh['name'];

        // Temporarily remove listeners so loading values doesn't mark dirty
        _nameCtrl.removeListener(_onFieldChanged);
        _priceCtrl.removeListener(_onFieldChanged);
        _descCtrl.removeListener(_onFieldChanged);

        _nameCtrl.text   = fresh['name']  ?? '';
        _priceCtrl.text  = fresh['price'].toString();
        _descCtrl.text   = fresh['description'] ?? '';
        isAvailable      = fresh['is_available'] == 1;
        _pickedFileName  = null;
        _pickedFileBytes = null;
        _pickedFilePath  = null;
        _isDirty         = false;

        _nameCtrl.addListener(_onFieldChanged);
        _priceCtrl.addListener(_onFieldChanged);
        _descCtrl.addListener(_onFieldChanged);
      });
    } catch (_) { _showError('Failed to load item details'); }
    finally { setState(() => isLoadingItem = false); }
  }


  Future<void> _saveItem() async {
    if (selectedItem == null) return;
    setState(() { isSaving = true; });

    try {
      int? newImageId;

      // 1. Upload image if the user picked one
      if (_pickedFileName != null) {
        final bytes = _pickedFileBytes ??
            ((!kIsWeb && _pickedFilePath != null)
                ? await File(_pickedFilePath!).readAsBytes()
                : null);

        if (bytes != null) {
          // TODO: replace with your actual file-upload service call
          // e.g.: newImageId = await MenuService.uploadImage(bytes, _pickedFileName!);
          newImageId = await MenuService.uploadImage(bytes, _pickedFileName!);
        }
      }

      // 2. Build the payload
      final payload = <String, dynamic>{
        'name':         _nameCtrl.text.trim(),
        'price':        double.tryParse(_priceCtrl.text) ?? 0,
        'description':  _descCtrl.text.trim(),
        'is_available': isAvailable ? 1 : 0,
      };
      if (newImageId != null) payload['image_id'] = newImageId;

      // 3. Persist
      await MenuService.updateMenuItem(selectedItem['id'], payload);

      // 4. Refresh list + clear dirty / picked state
      setState(() {
        selectedItemName = _nameCtrl.text.trim(); // update sidebar label live
        _isDirty         = false;
        _pickedFileName  = null;
        _pickedFileBytes = null;
        _pickedFilePath  = null;
      });
      _loadItems(selectedCategoryId!);
      _showSuccess('Item updated successfully');
    } catch (e) {
      debugPrint('Save error: $e');
      _showError('Failed to save changes');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _deleteItem(dynamic item) async {
    if (item == null) return;
    try {
      await MenuService.deleteMenuItem(item['id']);
      setState(() {
        items.removeWhere((i) => i['id'] == item['id']);
        _filteredItems = _filter(items, _itemSearch);
        if (selectedItem?['id'] == item['id']) {
          selectedItem = null; selectedItemName = null; _isDirty = false;
        }
      });
      _showSuccess('Item deleted');
    } catch (_) { _showError('Delete failed'); }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    try {
      await MenuService.deleteCategory(category['id']);

      categories.removeWhere((c) => c['id'] == category['id']);

      if (selectedCategoryId == category['id']) {
        selectedItem = null;
        selectedItemName = null;
        items.clear();
        _filteredItems.clear();
        _isDirty = false;

        if (categories.isNotEmpty) {
          selectedCategoryId = categories.first['id'];
          await _loadItems(selectedCategoryId!);
        } else {
          selectedCategoryId = null;
        }
      }

      setState(() {});

      _showSuccess("Category deleted successfully.");
    } catch (e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // ── File picker ───────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
        withReadStream: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      setState(() {
        _pickedFileName  = file.name;
        _pickedFileBytes = kIsWeb ? file.bytes : null;
        _pickedFilePath  = kIsWeb ? null : file.path;
        _isDirty         = true;   // new image = unsaved change
      });
    } catch (e) { debugPrint('Picker error: $e'); }
  }

  // ── Discard-changes guard ─────────────────────────────────────────────────

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Unsaved Changes',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: _kDark)),
            const SizedBox(height: 8),
            Text('You have unsaved changes. Discard them?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5,
                    color: _kDark.withOpacity(0.6))),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _OutlineBtn(
                label: 'Keep Editing',
                onTap: () => Navigator.pop(ctx, false),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pop(ctx, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Text('Discard',
                      style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    return result ?? false;
  }

  // ── Snackbars ─────────────────────────────────────────────────────────────

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ),
  );

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: _kRed,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(
                    title: 'MENU MANAGEMENT', onLogout: widget.onLogout),
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

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(children: [
        _Pill(
          icon: Icons.category_outlined,
          label: '${categories.length} Categories',
          color: _kPrimary,
        ),
        const SizedBox(width: 12),
        _Pill(
          icon: Icons.fastfood_outlined,
          label: '${items.length} Items',
          color: _kSecondary,
        ),
        const Spacer(),
        _OutlineBtn(
          label: '+ Category',
          icon: Icons.category_outlined,
          onTap: () => _showAddDialog(type: 'category'),
        ),
        const SizedBox(width: 10),
        // ✅ FIX: removed Icons.add_rounded so the + doesn't appear twice
        //    The label already starts with '+' — no icon needed here
        _FilledBtn(
          label: '+ Add Item',
          onTap: () => _showAddDialog(type: 'item'),
        ),
      ]),
    );
  }

  // ── Three-panel layout ────────────────────────────────────────────────────

  Widget _buildPanels() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: _kDark.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 210, child: _buildCategoryPanel()),
        _vDivider(),
        SizedBox(width: 260, child: _buildItemsPanel()),
        _vDivider(),
        Expanded(child: _buildDetailsPanel()),
      ]),
    );
  }

  Widget _vDivider() =>
      VerticalDivider(width: 1, thickness: 1, color: _kBorder);

  // ─────────────────────────────────────────────────────────────────────────
  // PANEL 1 — CATEGORIES
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryPanel() {
    return Column(children: [
      _PanelHeader(
        title: 'CATEGORIES',
        trailing: Text('${categories.length}',
            style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w800, color: _kPrimary)),
      ),
      Expanded(
        child: categories.isEmpty
            ? _emptyState(Icons.category_outlined, 'No categories yet')
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: categories.length,
                itemBuilder: (_, i) => _categoryTile(categories[i]),
              ),
      ),
    ]);
  }

  Widget _categoryTile(dynamic cat) {
    final selected = selectedCategoryId == cat['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => _onSelectCategory(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.only(
              left: 12, right: 8, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: selected ? _kPrimary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _kPrimary.withOpacity(0.35)
                  : Colors.transparent,
            ),
          ),
          child: Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _kPrimary : _kPrimary.withOpacity(0.25),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(cat['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? _kPrimary
                        : _kDark.withOpacity(0.65),
                  )),
            ),
            // Delete category
            Tooltip(
              message: 'Delete category',
              child: GestureDetector(
                onTap: () => _confirmDeleteCategory(cat),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 15, color: _kRed),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PANEL 2 — ITEMS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildItemsPanel() {
    return Column(children: [
      _PanelHeader(
        title: 'ITEMS',
        trailing: Text('${_filteredItems.length}',
            style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w800, color: _kSecondary)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: _SearchField(
          controller: _itemSearchCtrl,
          hint: 'Search items...',
          onChanged: _onSearchChanged,
        ),
      ),
      Expanded(
        child: _filteredItems.isEmpty
            ? _emptyState(Icons.fastfood_outlined,
                _itemSearch.isNotEmpty ? 'No results' : 'No items yet')
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                itemCount: _filteredItems.length,
                itemBuilder: (_, i) => _itemTile(_filteredItems[i]),
              ),
      ),
    ]);
  }

  Widget _itemTile(dynamic item) {
    final selected  = selectedItemName == item['name'];
    final available = item['is_available'] == 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => _onSelectItem(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? _kSecondary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _kSecondary.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item['name'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: _kDark,
                    )),
                const SizedBox(height: 2),
                Text('₱${item['price']}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kSecondary)),
              ]),
            ),
            // ✅ Show unsaved-changes dot on the item currently being edited
            if (selected && _isDirty)
              Container(
                width: 7, height: 7,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade400),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: available
                    ? _kGreen.withOpacity(0.1)
                    : _kRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                available ? 'On' : 'Off',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: available ? _kGreen : _kRed,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PANEL 3 — DETAILS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDetailsPanel() {
    if (selectedItemName == null) {
      return Column(children: [
        const _PanelHeader(title: 'ITEM DETAILS'),
        Expanded(child: _emptyState(Icons.edit_note_outlined,
            'Select an item to view and edit')),
      ]);
    }

    if (isLoadingItem) {
      return Column(children: [
        const _PanelHeader(title: 'ITEM DETAILS'),
        const Expanded(
            child: Center(
                child: CircularProgressIndicator(color: _kPrimary))),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _PanelHeader(
        title: 'ITEM DETAILS',
        // ✅ Show unsaved indicator in the panel header
        trailing: _isDirty
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade400),
                  ),
                  const SizedBox(width: 5),
                  Text('Unsaved',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700)),
                ]),
              )
            : null,
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            // ── Item header ──────────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedItem['image_url'] != null &&
                        selectedItem['image_url'].toString().isNotEmpty
                    ? Image.network(
                        getImageUrl(selectedItem['image_url']),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood_rounded,
                          color: _kPrimary,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: _kPrimary,
                        size: 24,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(selectedItemName!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kDark)),
                  const SizedBox(height: 2),
                  Text(
                    categories.firstWhere(
                      (c) => c['id'] == selectedCategoryId,
                      orElse: () => {'name': ''})['name'] ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: _kDark.withOpacity(0.45),
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
              // Availability toggle
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? _kGreen.withOpacity(0.07)
                      : _kRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable
                        ? _kGreen.withOpacity(0.3)
                        : _kRed.withOpacity(0.25),
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAvailable ? _kGreen : _kRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isAvailable ? _kGreen : _kRed),
                  ),
                  const SizedBox(width: 10),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isAvailable,
                      onChanged: (v) =>
                          setState(() { isAvailable = v; _isDirty = true; }),
                      activeColor: Colors.white,
                      activeTrackColor: _kGreen,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: _kRed.withOpacity(0.5),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ]),
              ),
            ]),

            const SizedBox(height: 24),
            const Divider(color: _kBorder, height: 1),
            const SizedBox(height: 24),

            // ── Fields ────────────────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _FormField(
                label: 'Item Name',
                ctrl: _nameCtrl,
                hint: 'e.g. Chicken Burger',
              )),
              const SizedBox(width: 16),
              SizedBox(width: 130, child: _FormField(
                label: 'Price (₱)',
                ctrl: _priceCtrl,
                hint: '0.00',
                keyboard: const TextInputType.numberWithOptions(
                    decimal: true),
              )),
            ]),
            const SizedBox(height: 16),
            _FormField(
              label: 'Description',
              ctrl: _descCtrl,
              hint: 'Describe the item...',
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // ── Image upload ──────────────────────────────────────────────
            const _Label('Item Photo'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: _kBg.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pickedFileName != null
                        ? _kPrimary.withOpacity(0.5)
                        : _kBorder,
                    width: _pickedFileName != null ? 1.5 : 1,
                  ),
                ),
                child: _pickedFileName != null
                    ? _buildImagePreview()
                    :  _buildExistingImageOrPlaceholder(),
              ),
            ),

            const SizedBox(height: 28),
            const Divider(color: _kBorder, height: 1),
            const SizedBox(height: 20),

            // ── Action buttons ────────────────────────────────────────────
            Row(children: [
              // ✅ Save button shows spinner while saving
              isSaving
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : _FilledBtn(
                      label: 'Save Changes',
                      icon: Icons.save_outlined,
                      onTap: _saveItem,
                    ),
              const SizedBox(width: 10),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildExistingImageOrPlaceholder() {
    final imageName = selectedItem?['image_url'];

    if (imageName == null || imageName.toString().isEmpty) {
      return _buildUploadPlaceholder();
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              getImageUrl(imageName),
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return Container(
                  width: 88,
                  height: 88,
                  color: _kPrimary.withOpacity(0.08),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 88,
                  height: 88,
                  color: _kPrimary.withOpacity(0.08),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: _kPrimary,
                    size: 32,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Click "Replace Image" to upload a new one',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kDark.withOpacity(0.35),
                  ),
                ),

                const SizedBox(height: 8),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _kPrimary.withOpacity(0.25),
                      ),
                    ),
                    child: const Text(
                      'Replace Image',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ── Image widgets ─────────────────────────────────────────────────────────


  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _pickedFileBytes != null
              ? Image.memory(_pickedFileBytes!,
                  width: 88, height: 88, fit: BoxFit.cover)
              : (!kIsWeb && _pickedFilePath != null)
                  ? Image.file(File(_pickedFilePath!),
                      width: 88, height: 88, fit: BoxFit.cover)
                  : Container(
                      width: 88, height: 88,
                      color: _kPrimary.withOpacity(0.08),
                      child: const Icon(Icons.image_outlined,
                          color: _kPrimary, size: 32)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_pickedFileName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: _kDark)),
            const SizedBox(height: 8),
            Row(children: [
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _kPrimary.withOpacity(0.25)),
                  ),
                  child: const Text('Change',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _pickedFileName  = null;
                  _pickedFileBytes = null;
                  _pickedFilePath  = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _kRed.withOpacity(0.2)),
                  ),
                  child: const Text('Remove',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700, color: _kRed)),
                ),
              ),
            ]),
          ],
        )),
      ]),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.cloud_upload_outlined,
            color: _kPrimary.withOpacity(0.5), size: 22),
      ),
      const SizedBox(height: 8),
      Text('Click to upload photo',
          style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kDark.withOpacity(0.5))),
      const SizedBox(height: 2),
      Text('PNG, JPG, WEBP supported',
          style: TextStyle(fontSize: 10,
              color: _kDark.withOpacity(0.3))),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  void _showAddDialog({required String type}) {
    final isItem    = type == 'item';
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl  = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isItem
                        ? Icons.fastfood_outlined
                        : Icons.category_outlined,
                    color: _kPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(isItem ? 'Add New Item' : 'Add Category',
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w800, color: _kDark)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: _kDark),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              const Divider(color: _kBorder, height: 1),
              const SizedBox(height: 20),
              _FormField(
                label: isItem ? 'Item Name' : 'Category Name',
                ctrl: nameCtrl,
                hint: isItem ? 'e.g. Nutella Frappe' : 'e.g. Beverages',
              ),
              if (isItem) ...[
                const SizedBox(height: 14),
                _FormField(
                  label: 'Price (₱)',
                  ctrl: priceCtrl,
                  hint: '0.00',
                  keyboard: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 14),
                _FormField(
                  label: 'Description',
                  ctrl: descCtrl,
                  hint: 'Describe the item...',
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _OutlineBtn(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(ctx)),
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
                          'name':        name,
                          'price':       double.tryParse(priceCtrl.text) ?? 0,
                          'description': descCtrl.text.trim(),
                          'category_id': selectedCategoryId,
                        });
                        _loadItems(selectedCategoryId!);
                      } else {
                        await MenuService.addCategory(name);
                        _loadCategories();
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _showSuccess(
                          isItem ? 'Item added' : 'Category added');
                    } catch (_) { _showError('Failed to save'); }
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    if (item == null) return;
    _showConfirmDialog(
      icon: Icons.delete_outline_rounded,
      title: 'Delete Item',
      message:
          'Permanently delete "${item['name']}"?\nThis cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: () => _deleteItem(item),
    );
  }

  void _confirmDeleteCategory(dynamic cat) {
    if (cat == null) return;
    _showConfirmDialog(
      icon: Icons.category_outlined,
      title: 'Delete Category',
      message: 'Delete the "${cat['name']}" category?',
      warning:
          'All items inside this category may also be removed. This action cannot be undone.',
      confirmLabel: 'Delete Category',
      onConfirm: () => _deleteCategory(cat),
    );
  }

  void _showConfirmDialog({
    required IconData icon,
    required String title,
    required String message,
    String? warning,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: _kRed, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: _kDark)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5,
                    color: _kDark.withOpacity(0.6))),
            if (warning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.2)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 15, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(warning,
                        style: TextStyle(fontSize: 11, height: 1.6,
                            color: Colors.orange.shade800)),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _OutlineBtn(
                  label: 'Cancel',
                  onTap: () => Navigator.pop(ctx)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () { Navigator.pop(ctx); onConfirm(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(confirmLabel,
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _emptyState(IconData icon, String msg) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 36, color: _kPrimary.withOpacity(0.2)),
      const SizedBox(height: 10),
      Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12,
              color: _kDark.withOpacity(0.35),
              fontWeight: FontWeight.w500)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _PanelHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6, color: _kPrimary)),
        if (trailing != null) ...[const Spacer(), trailing!],
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kDark.withOpacity(0.55), letterSpacing: 0.3));
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final int maxLines;
  final TextInputType? keyboard;

  const _FormField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Label(label),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w500, color: _kDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 13, color: _kDark.withOpacity(0.25)),
          filled: true,
          fillColor: _kBg.withOpacity(0.35),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: _kPrimary, width: 1.5)),
        ),
      ),
    ]);
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12, color: _kDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: _kDark.withOpacity(0.35)),
        prefixIcon: Icon(Icons.search_rounded,
            size: 16, color: _kDark.withOpacity(0.4)),
        filled: true,
        fillColor: _kBg.withOpacity(0.4),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: _kPrimary, width: 1.4)),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _FilledBtn({required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [BoxShadow(
              color: _kPrimary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: Colors.white)),
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
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? _kRed : _kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: danger ? _kRed.withOpacity(0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}