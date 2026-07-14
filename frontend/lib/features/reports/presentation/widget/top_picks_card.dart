import 'package:flutter/material.dart';
import './base_card.dart';

const Color _accent  = Color(0xFF758C6D);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);
const Color _muted   = Color(0xFF8A8070);

class TopPicksCard extends StatelessWidget {
  final List<dynamic> menuItems;

  const TopPicksCard({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return const BaseCard(
        title: 'TOP PICKS',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu_outlined,
                size: 42,
                color: _muted,
              ),
              SizedBox(height: 12),
              Text(
                'No menu sales found',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'No completed orders were recorded during this period.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final displayItems = menuItems.take(10).toList();

    return BaseCard(
      title: 'TOP PICKS',
      trailing: _pill('${displayItems.length} ITEMS', _gold),
      child: ConstrainedBox(
        // UX Principle: Set to 112px so the 1st row shows completely, 
        // and the 2nd row peeks through by ~15-20px to indicate vertical scroll affordance.
        constraints: const BoxConstraints(maxHeight: 112),
        child: GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,        // Strict 5 columns
            crossAxisSpacing: 6,      // Tight horizontal gaps
            mainAxisSpacing: 6,       // Tight vertical gaps
            childAspectRatio: 1.85,   // Landscape layout ratio dramatically lowers total tile height
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, i) {
            return _PickTile(
              item: displayItems[i],
              rank: i + 1,
            );
          },
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  final dynamic item;
  final int rank;

  const _PickTile({
    required this.item,
    required this.rank,
  });

  String getMenuImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return '';
    }
    return 'http://localhost:3006/uploads/menu-items/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final String name = item['name']?.toString() ?? 'Unknown Item';
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;
    final int sold = int.tryParse(item['total_sold'].toString()) ?? 0;
    final String imageUrl = getMenuImageUrl(item['image_url']?.toString());
    final double revenue = price * sold;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileHeight = constraints.maxHeight;
        
        // Size components relative to the shrunken tile height
        final double imageSize = tileHeight * 0.78; 
        final double titleSize = (tileHeight * 0.19).clamp(9.0, 11.0);
        final double statLabelSize = (tileHeight * 0.14).clamp(6.5, 7.5);
        final double statValueSize = (tileHeight * 0.18).clamp(9.0, 10.5);
        final double badgeSize = (tileHeight * 0.15).clamp(7.5, 9.0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.black.withOpacity(.04),
            ),
          ),
          padding: const EdgeInsets.all(4),
          // Changed to Row: side-by-side components create the shortest height possible
          child: Row(
            children: [
              //---------------- LEFT: IMAGE WITH OVERLAY BADGE ----------------//
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                            )
                          : _buildPlaceholderIcon(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                      decoration: const BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        "#$rank",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: badgeSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 5),

              //---------------- RIGHT: DATA BLOCK ----------------//
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Item name text with completely removed surrounding padding
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                        color: _dark,
                        height: 1.0, // Removes text leading line height issues
                      ),
                    ),
                    
                    const SizedBox(height: 4),

                    // Micro stats horizontal line block
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "SOLD",
                                style: TextStyle(
                                  fontSize: statLabelSize,
                                  color: _muted,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  sold.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: statValueSize,
                                    color: _dark,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          width: 0.4,
                          height: 8,
                          color: Colors.black12,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                        ),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "REV",
                                style: TextStyle(
                                  fontSize: statLabelSize,
                                  color: _muted,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "₱${revenue.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: statValueSize,
                                    color: _accent,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade50,
      child: const Icon(
        Icons.fastfood_rounded,
        size: 11,
        color: _muted,
      ),
    );
  }
}

Widget _pill(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 1.2,
            color: color)),
  );
}