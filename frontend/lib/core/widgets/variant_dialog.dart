import 'package:flutter/material.dart';
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

                    if (requiresVariant) ...[
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                      _buildVariantSection(),
                    ],

                    if (requiresFlavor) ...[
                      if (requiresVariant)
                        const SizedBox(height: 20),

                      _buildFlavorSection(),
                    ],

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
      if (requiresVariant && selectedVariant == null) {
        return const SizedBox();
      }

      final requiredFlavors = this.requiredFlavors;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),

          const SizedBox(height: 8),

          Text(
            "Select Flavors (${selectedFlavors.length}/$requiredFlavors)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          ...flavors.map((flavor) {
            final isSelected =
                selectedFlavors.any((f) => f.id == flavor.id);

            return CheckboxListTile(
              value: isSelected,
              title: Text(flavor.flavorName),

              subtitle: !flavor.isAvailable
                  ? const Text(
                      "Unavailable",
                      style: TextStyle(color: Colors.red),
                    )
                  : null,

              controlAffinity:
                  ListTileControlAffinity.leading,

              contentPadding: EdgeInsets.zero,

              onChanged: !flavor.isAvailable
                  ? null
                  : (checked) {

                      setState(() {

                        if (checked == true) {

                          if (!isSelected) {

                            if (selectedFlavors.length <
                                requiredFlavors) {

                              selectedFlavors.add(flavor);

                            } else {

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Only $requiredFlavors flavor(s) can be selected.",
                                  ),
                                ),
                              );

                            }

                          }

                        } else {

                          selectedFlavors.removeWhere(
                            (f) => f.id == flavor.id,
                          );

                        }

                      });

                    },
            );
          }),
        ],
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
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"),
      ),

      ElevatedButton(
        onPressed: !canAddToCart
            ? null
            : () {
                Navigator.pop(context, {
                  "variant": selectedVariant,
                  "flavors": selectedFlavors,
                });
              },
        child: const Text("Add to Cart"),
      )
    ];
  }
}