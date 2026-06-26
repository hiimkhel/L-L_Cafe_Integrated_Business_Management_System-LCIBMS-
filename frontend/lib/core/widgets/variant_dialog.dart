import 'package:flutter/material.dart';
import 'package:frontend/core/models/flavor_models.dart';
import 'package:frontend/core/models/menu_item.dart';
import 'package:frontend/core/models/menu_item_variant.dart';
import 'package:frontend/core/services/menu_service.dart';

class VariantDialog extends StatefulWidget {
  final MenuItem item;

  const VariantDialog({
    super.key,
    required this.item,
  });

  @override
  State<VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<VariantDialog> {
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedVariants =
          await MenuService.fetchVariants(widget.item.id);

      final loadedFlavors =
          await MenuService.fetchFlavors();

      setState(() {
        variants = loadedVariants;
        flavors = loadedFlavors;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.name),
      content: SizedBox(
        width: 420,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildCategorySection(),

                    _buildVariantSection(),

                    _buildFlavorSection(),

                  ],
                ),
              ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Select Category",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        ...categories.map((category) {

          return RadioListTile<String>(
            value: category,
            groupValue: selectedCategory,
            title: Text(category),
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {

              setState(() {

                selectedCategory = value;

                selectedVariant = null;

                selectedFlavors.clear();

              });

            },
          );

        }),

      ],
    );
  }

  Widget _buildVariantSection() {

    if (selectedCategory == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Divider(),

        const SizedBox(height: 8),

        const Text(
          "Select Size",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        ...filteredVariants.map((variant) {

          return RadioListTile<MenuItemVariant>(
            value: variant,
            groupValue: selectedVariant,
            title: Text(variant.variantName),
            subtitle: Text(
              "₱${variant.price.toStringAsFixed(2)}",
            ),
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {

              setState(() {

                selectedVariant = value;

                selectedFlavors.clear();

              });

            },
          );

        }),

      ],
    );
  }

  Widget _buildFlavorSection() {

    if (selectedVariant == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Divider(),

        const SizedBox(height: 8),

        Text(
          "Select Flavors (${selectedVariant!.requiredFlavors})",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // We'll add the checkbox list here next.

      ],
    );
  }

  List<Widget> _buildActions() {

    return [

      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"),
      ),

      ElevatedButton(
        onPressed: null,
        child: const Text("Add to Cart"),
      ),

    ];

  }
}