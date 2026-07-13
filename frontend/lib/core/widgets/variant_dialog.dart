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
                    if (categories.length > 1) ...[
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                    ],

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

         Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return ChoiceChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                  selectedVariant = null;
                  selectedFlavors.clear();
                });
              },
            );
          }).toList(),
        ),

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
            "Select Option",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredVariants.map((variant) {
              final isSelected = selectedVariant?.id == variant.id;

              return ChoiceChip(
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      variant.variantName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₱${variant.price.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedVariant = variant;
                    selectedFlavors.clear();
                  });
                },
              );
            }).toList(),
          ),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Flavors",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${selectedFlavors.length}/$requiredFlavors",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Wrap(
          spacing: 8,
          runSpacing: 8,
          children: flavors.map((flavor) {
            final isSelected =
                selectedFlavors.any((f) => f.id == flavor.id);

            return FilterChip(
              label: Text(flavor.flavorName),

              selected: isSelected,

              onSelected: !flavor.isAvailable
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          if (selectedFlavors.length < requiredFlavors) {
                            selectedFlavors.add(flavor);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Only $requiredFlavors flavor(s) can be selected.",
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