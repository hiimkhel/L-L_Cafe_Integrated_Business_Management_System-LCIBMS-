import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class HeaderBar2 extends StatefulWidget {
  final String title;
  final Function(String) onSearch;
  final VoidCallback onExport;

  const HeaderBar2({
    super.key,
    required this.title,
    required this.onSearch,
    required this.onExport,
  });

  @override
  State<HeaderBar2> createState() => _HeaderBar2State();
}

class _HeaderBar2State extends State<HeaderBar2> {
  Timer? _debounce;

  // Handles search with a 500ms delay to save API calls
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          _backButton(context),
          const SizedBox(width: 20),
          
          /// TITLE
          Text(widget.title, style: AppTextStyles.title),
          
          const SizedBox(width: 40),

          /// SEARCH BAR
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Search by Order ID or Customer...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          /// EXPORT CSV BUTTON
          ElevatedButton.icon(
            onPressed: widget.onExport,
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text("Export CSV"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
      ),
    );
  }
}