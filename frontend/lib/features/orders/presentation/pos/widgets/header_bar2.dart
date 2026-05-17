import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/dashboard/presentation/pos/order_entry.dart';
import 'package:intl/intl.dart'; 
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
  DateTime? _startDate;
  DateTime? _endDate;
  Timer? _debounce;

  // Controllers to handle text input display
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  void _triggerUpdate() {
    DateTimeRange? range;
    if (_startDate != null && _endDate != null) {
      range = DateTimeRange(start: _startDate!, end: _endDate!);
    }
    widget.onFilterChanged(_currentSearch, _selectedDateFilter, customRange: range);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// MAIN HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(color: AppColors.background),
          child: Row(
            children: [
              _backButton(context),
              const SizedBox(width: 24),
              _titleSection(),
              const Spacer(),
              _searchField(),
              const SizedBox(width: 16),
              _exportButton(),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.border),

        /// FILTER ROW
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.05)),
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: AppColors.tertiary),
              const SizedBox(width: 12),
              const Text("FILTER BY:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.tertiary)),
              const SizedBox(width: 16),
              _dateDropdown(),
              
              /// INLINE DATE INPUTS
              if (_selectedDateFilter == 'custom') ...[
                const SizedBox(width: 16),
                _inlineDateInput("Start Date", _startController, (date) => _startDate = date),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("to", style: TextStyle(color: AppColors.tertiary)),
                ),
                _inlineDateInput("End Date", _endController, (date) => _endDate = date),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _startDate = _endDate = null;
                      _startController.clear();
                      _endController.clear();
                    });
                    _triggerUpdate();
                  },
                  icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                  tooltip: "Clear Dates",
                )
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _inlineDateInput(String hint, TextEditingController controller, Function(DateTime) onSelected) {
    return Container(
      width: 180,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: TextAlign.center, // This will now be perfectly centered
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onSurface: AppColors.secondary,
                ),
              ),
              child: child!,
            ),
          );
          if (date != null) {
            setState(() {
              controller.text = DateFormat('MMM dd, yyyy').format(date);
              onSelected(date);
            });
            _triggerUpdate();
          }
        },
        style: const TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w700, 
          color: AppColors.secondary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11, color: AppColors.tertiary.withOpacity(0.6)),
          // We use prefix and suffix to balance the centering logic
          prefixIcon: const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primary),
          suffixIcon: const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.transparent), 
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _dateDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDateFilter,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: 'all', child: Text("All Time")),
            DropdownMenuItem(value: 'today', child: Text("Today")),
            DropdownMenuItem(value: 'yesterday', child: Text("Yesterday")),
            DropdownMenuItem(value: 'custom', child: Text("Custom Range")),
          ],
          onChanged: (val) {
            setState(() {
              _selectedDateFilter = val!;
              if (val != 'custom') {
                _startDate = _endDate = null;
                _startController.clear();
                _endController.clear();
              }
            });
            _triggerUpdate();
          },
        ),
      ),
    );
  }

  // --- Reuse previous logic for buttons/search ---
  Widget _titleSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.secondary)),
    const Text("HISTORICAL ARCHIVE DATA", style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
  ]);

  Widget _searchField() => Container(
    width: 300, height: 48,
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
    child: TextField(
      onChanged: (val) {
        _currentSearch = val;
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), _triggerUpdate);
      },
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: const InputDecoration(
        hintText: "Search ID or Customer...",
        hintStyle: TextStyle(fontSize: 14, color: Color.fromARGB(110, 0, 0, 0)),
        prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  );

  Widget _exportButton() => SizedBox(height: 48, child: ElevatedButton.icon(
    onPressed: widget.onExport,
    icon: const Icon(Icons.file_download_outlined, size: 20, color: Colors.white,), 
    label: const Text("EXPORT CSV"),
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  ));

  Widget _backButton(BuildContext context) => InkWell(
    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => POSOrderScreen())),
    child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.card), child: const Icon(Icons.arrow_back, color: AppColors.primary)),
  );
}