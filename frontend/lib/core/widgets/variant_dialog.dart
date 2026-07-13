import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/models/flavor_models.dart';
import 'package:frontend/core/models/menu_item.dart';
import 'package:frontend/core/models/menu_item_variant.dart';
import 'package:frontend/core/services/menu_service.dart';

class CustomizeItemDialog extends StatefulWidget {
  final MenuItem item;

  const CustomizeItemDialog({
    super.key,
    required this.item,
  });

  @override
  State<CustomizeItemDialog> createState() => _CustomizeItemDialogState();
}

class _CustomizeItemDialogState extends State<CustomizeItemDialog> {
  List<Flavor> flavors = [];
  List<MenuItemVariant> variants = [];

  MenuItemVariant? selectedVariant;
  String? selectedCategory;

  List<Flavor> selectedFlavors = [];

  bool isLoading = true;

  static const List<String> categoryOrder = [
    'Ala Carte',
    'with Rice',
    'Tray',
  ];

  List<String> get categories {
    return categoryOrder
        .where(
          (category) =>
              variants.any((variant) => variant.category == category),
        )
        .toList();
  }

  List<MenuItemVariant> get filteredVariants {
    if (selectedCategory == null) return [];

    return variants
        .where((variant) => variant.category == selectedCategory)
        .toList();
  }

  bool get requiresVariant => widget.item.hasVariants;

  bool get requiresFlavor => widget.item.hasFlavors;

  /// Number of flavors the customer must choose.
  int get requiredFlavors {
    if (!requiresFlavor) return 0;

    // Items without variants default to one flavor.
    if (!requiresVariant) {
      return 1;
    }

    return selectedVariant?.requiredFlavors ?? 0;
  }

  
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      List<MenuItemVariant> loadedVariants = [];
      List<Flavor> loadedFlavors = [];

      final futures = <Future<void>>[];

      if (requiresVariant) {
        futures.add(
          MenuService.fetchVariants(widget.item.id).then((value) {
            loadedVariants = value;
          }),
        );
      }

      if (requiresFlavor) {
        futures.add(
          MenuService.fetchFlavors(widget.item.id).then((value) {
            loadedFlavors = value;
          }),
        );
      }

      await Future.wait(futures);

      if (!mounted) return;

      setState(() {
        variants = loadedVariants;
        flavors = loadedFlavors;
        if (categories.length == 1) {
          selectedCategory = categories.first;
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        width: 500,
        child: isLoading
            ? const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Header
                  _buildHeader(),

                  const Divider(height: 1),

                  // Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (requiresVariant) ...[
                            if (categories.length > 1)
                              _buildCategorySection(),

                            _buildVariantSection(),
                          ],

                          if (requiresFlavor)
                            _buildFlavorSection(),

                        ],
                      ),
                    ),
                  ),

                 const Divider(height: 1),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        _buildSelectionSummary(),

                        Row(
                          children: _buildActions(),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Customize your order",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

        ],
      ),
    );
  }

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (trailing != null)
                trailing,

            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.secondary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected
            ? AppColors.secondary
            : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required bool enabled,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.secondary,
      backgroundColor: Colors.white,
      disabledColor: Colors.grey.shade200,
      side: BorderSide(
        color: selected
            ? AppColors.secondary
            : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
        color: !enabled
            ? Colors.grey
            : selected
                ? Colors.white
                : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      onSelected: enabled ? onSelected : null,
    );
  }

  Widget _buildCategorySection() {
    return _buildSectionCard(
      title: "Category",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categories.map((category) {
          return _buildChoiceChip(
            label: category,
            selected: selectedCategory == category,
            onTap: () {
              setState(() {
                selectedCategory = category;
                selectedVariant = null;
                selectedFlavors.clear();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVariantSection() {
    if (selectedCategory == null) {
      return const SizedBox();
    }

    return _buildSectionCard(
      title: "Option",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: filteredVariants.map((variant) {
          return _buildChoiceChip(
            label: variant.variantName,
            selected: selectedVariant?.id == variant.id,
            onTap: () {
              setState(() {
                selectedVariant = variant;
                selectedFlavors.clear();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlavorSection() {
    if (requiresVariant && selectedVariant == null) {
      return const SizedBox();
    }

    final completed =
        selectedFlavors.length == requiredFlavors;

    return _buildSectionCard(
      title: "Flavors",
      trailing: _buildFlavorStatusBadge(completed),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: flavors.map((flavor) {
          final isSelected = selectedFlavors.any(
            (f) => f.id == flavor.id,
          );

          return _buildFilterChip(
            label: flavor.flavorName,
            selected: isSelected,
            enabled: flavor.isAvailable,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  if (selectedFlavors.length <
                      requiredFlavors) {
                    selectedFlavors.add(flavor);
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "Maximum of $requiredFlavors flavor(s) can be selected.",
                        ),
                      ),
                    );
                  }
                } else {
                  selectedFlavors.removeWhere(
                    (f) => f.id == flavor.id,
                  );
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlavorStatusBadge(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.secondary
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 16,
            color: completed
                ? Colors.white
                : Colors.black87,
          ),

          const SizedBox(width: 6),

          Text(
            "${selectedFlavors.length}/$requiredFlavors",
            style: TextStyle(
              color: completed
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
    

  bool get canAddToCart {
    if (requiresVariant && selectedVariant == null) {
      return false;
    }

    if (requiresFlavor &&
        selectedFlavors.length != requiredFlavors) {
      return false;
    }

    return true;
  }

  
  List<Widget> _buildActions() {
    return [

      Expanded(
        child: OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Cancel"),
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: canAddToCart
              ? () {
                  Navigator.pop(context, {
                    "variant": selectedVariant,
                    "flavors": selectedFlavors,
                  });
                }
              : null,
          icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
          label: const Text("Add to Cart"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildSelectionSummary() {
    final option = selectedVariant?.variantName ?? "No option selected";

    final flavors = selectedFlavors.isEmpty
        ? "No flavors"
        : selectedFlavors
            .map((e) => e.flavorName)
            .join(", ");

    final price = selectedVariant?.price ?? widget.item.price;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.receipt_long,
            color: AppColors.secondary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (requiresFlavor)
                  Text(
                    flavors,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

              ],
            ),
          ),

          Text(
            "₱${price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}