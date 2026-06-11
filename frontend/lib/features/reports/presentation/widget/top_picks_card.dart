import 'package:flutter/material.dart';
import './base_card.dart';

const Color _accent  = Color(0xFF758C6D);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);
const Color _muted   = Color(0xFF8A8070);

class TopPicksCard extends StatelessWidget {
  final List<dynamic> menuItems;

  const TopPicksCard({
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

    // Limit to exactly 10 items maximum if it's a Top 10 list
    final displayItems = menuItems.take(10).toList();

    return BaseCard(
      title: 'TOP PICKS',
      trailing: _pill('${displayItems.length} ITEMS', _gold),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 items per row
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // Adjusted aspect ratio to give vertical height for the stacked text metrics
          childAspectRatio: 1.5, 
        ),
        itemCount: displayItems.length,
        itemBuilder: (_, i) => _PickTile(
          item: displayItems[i],
          rank: i + 1,
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
    
    final String imageUrl = getMenuImageUrl(
      item['image_url']?.toString(),
    );

    final double totalRevenue = price * sold;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16), // Softer corners for modern UI
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered alignment strategy
        children: [
          // 1. HEADER: Image & Rank Badge Overlay Stack
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),
              // Floating Rank Badge over the image
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      color: Colors.white, // Crisp white contrast against accent theme
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. MIDDLE: Centered Item Typography
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _dark,
                  height: 1.15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1, color: Colors.black12), // Subtle separator 
          const SizedBox(height: 6),

          // 3. BOTTOM: Balanced Centered Metrics Box
          Row(
            children: [
              // Sold Counter
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SOLD',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sold.toString(),
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical Divider line between stats
              Container(width: 1, height: 16, color: Colors.black12),

              // Revenue Counter
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'REVENUE',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '₱${totalRevenue.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Extracted Helper Method for Clean Fallbacks
  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade50,
      child: const Icon(
        Icons.fastfood_rounded,
        size: 20,
        color: _muted,
      ),
    );
  }
}

Widget _pill(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 1.2,
            color: color)),
  );
}