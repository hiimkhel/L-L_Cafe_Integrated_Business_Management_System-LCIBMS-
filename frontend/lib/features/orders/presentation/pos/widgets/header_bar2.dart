import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class HeaderBar2 extends StatefulWidget {
  final String title;
  final Function(String query, String dateFilter, {DateTimeRange? customRange}) onFilterChanged;
  final VoidCallback onExport;

  const HeaderBar2({
    super.key,
    required this.title,
    required this.onFilterChanged,
    required this.onExport,
  });

  @override
  State<HeaderBar2> createState() => _HeaderBar2State();
}

class _HeaderBar2State extends State<HeaderBar2> {
  String _currentSearch = '';
  String _selectedDateFilter = 'all'; 
  DateTimeRange? _customRange;
  Timer? _debounce;

  void _triggerUpdate() {
    widget.onFilterChanged(
      _currentSearch,
      _selectedDateFilter,
      customRange: _customRange,
    );
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _selectedDateFilter = 'custom';
      });
      _triggerUpdate();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          /// ROW 1: BACK BUTTON, TITLE, AND SEARCH
          Row(
            children: [
              _backButton(context),
              const SizedBox(width: 16),
              Text(widget.title, style: AppTextStyles.title),
              const SizedBox(width: 24),
              
              // Search Bar expanded in the first row
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _currentSearch = val;
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), _triggerUpdate);
                    },
                    decoration: const InputDecoration(
                      hintText: "Search by Order ID or Customer name...",
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ROW 2: FILTERS AND EXPORT BUTTON
          Row(
            children: [
              const Text("Filter by Date:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              
              // Date Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDateFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text("All Time")),
                      DropdownMenuItem(value: 'today', child: Text("Today")),
                      DropdownMenuItem(value: 'yesterday', child: Text("Yesterday")),
                      DropdownMenuItem(value: 'custom', child: Text("Custom Range...")),
                    ],
                    onChanged: (val) {
                      if (val == 'custom') {
                        _selectCustomRange();
                      } else {
                        setState(() {
                          _selectedDateFilter = val!;
                          _customRange = null;
                        });
                        _triggerUpdate();
                      }
                    },
                  ),
                ),
              ),

              if (_selectedDateFilter == 'custom' && _customRange != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Chip(
                    label: Text(
                      "${_customRange!.start.toString().split(' ')[0]} - ${_customRange!.end.toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() {
                        _selectedDateFilter = 'all';
                        _customRange = null;
                      });
                      _triggerUpdate();
                    },
                  ),
                ),

              const Spacer(),

              /// EXPORT BUTTON
              ElevatedButton.icon(
                onPressed: widget.onExport,
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text("Export CSV"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
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