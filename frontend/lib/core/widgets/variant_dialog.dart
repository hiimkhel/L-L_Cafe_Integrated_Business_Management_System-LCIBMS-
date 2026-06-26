import 'package:flutter/material.dart';
import 'package:frontend/core/models/menu_item.dart';
import 'package:frontend/core/services/menu_service.dart';
import 'package:frontend/core/models/menu_item_variant.dart';
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

  // <-- STEP 2 GOES HERE

  List<MenuItemVariant> variants = [];

  MenuItemVariant? selectedVariant;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVariants();
  }

  Future<void> loadVariants() async {
    variants = await MenuService.fetchVariants(widget.item.id);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.name),

      content: isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: variants.map((variant) {

                return RadioListTile<MenuItemVariant>(

                  value: variant,

                  groupValue: selectedVariant,

                  title: Text(
                      variant.variantName),

                  subtitle: Text(
                      "₱${variant.price}"),

                  onChanged: (value) {

                    setState(() {

                      selectedVariant = value;

                    });

                  },

                );

              }).toList(),
            ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);

          },

          child: const Text("Cancel"),

        ),

        ElevatedButton(

          onPressed:
              selectedVariant == null
                  ? null
                  : () {

                      Navigator.pop(
                        context,
                        selectedVariant,
                      );

                    },

          child: const Text("Next"),

        )

      ],

    );
  }
}