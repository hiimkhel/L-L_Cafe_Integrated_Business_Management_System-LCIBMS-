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
      child: LayoutBuilder(
        builder: (context, constraints) {

          int columns;
          

          if (constraints.maxWidth >= 1400) {
            columns = 5;
          } else if (constraints.maxWidth >= 1100) {
            columns = 4;
          } else if (constraints.maxWidth >= 800) {
            columns = 3;
          } else {
            columns = 2;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemCount: displayItems.length,
            itemBuilder: (_, i) => _PickTile(
              item: displayItems[i],
              rank: i + 1,
            ),
          );
        },
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
    final double price =
        double.tryParse(item['price'].toString()) ?? 0.0;
    final int sold =
        int.tryParse(item['total_sold'].toString()) ?? 0;

    final String imageUrl = getMenuImageUrl(
      item['image_url']?.toString(),
    );

    final double revenue = price * sold;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;

        final imageSize = tileWidth * .38;
        final titleSize = tileWidth * .10;
        final statLabelSize = tileWidth * .055;
        final statValueSize = tileWidth * .085;
        final badgeSize = tileWidth * .065;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              //---------------- IMAGE ----------------//

              Stack(
                clipBehavior: Clip.none,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderIcon(),
                            )
                          : _buildPlaceholderIcon(),
                    ),
                  ),

                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: badgeSize * .6,
                        vertical: badgeSize * .25,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "#$rank",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: badgeSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: tileWidth * .08),

              //---------------- TITLE ----------------//

              Expanded(
                child: Center(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800,
                      fontSize: titleSize.clamp(10, 14),
                      color: _dark,
                      height: 1.15,
                    ),
                  ),
                ),
              ),

              const Divider(height: 16),

              //---------------- STATS ----------------//

              Row(
                children: [

                  Expanded(
                    child: Column(
                      children: [

                        Text(
                          "SOLD",
                          style: TextStyle(
                            fontSize:
                                statLabelSize.clamp(7, 10),
                            color: _muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          sold.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize:
                                statValueSize.clamp(10, 15),
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.black12,
                  ),

                  Expanded(
                    child: Column(
                      children: [

                        Text(
                          "REVENUE",
                          style: TextStyle(
                            fontSize:
                                statLabelSize.clamp(7, 10),
                            color: _muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          "₱${revenue.toStringAsFixed(0)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize:
                                statValueSize.clamp(10, 15),
                            color: _accent,
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
      },
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