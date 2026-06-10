import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';
import './card_header.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold = Color(0xFFA98258);
const Color _beige = Color(0xFFEFE2C9);
const Color _white = Colors.white;


class MenusCard extends StatelessWidget {
  final List<TopMenuItem> items;
  const MenusCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final top5    = items.take(5).toList();
    final maxSold = top5.isEmpty ? 1 : top5.first.sold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const CardHeader(title: 'TOP 5 MENUS'),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('BY SALES',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _gold)),
            ),
          ]),
          const SizedBox(height: 16),
          ...top5.asMap().entries.map((e) {
            final ratio = e.value.sold / maxSold;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: e.key < top5.length - 1 ? 16 : 0),
              child: _MenuItemTile(
                  item: e.value, ratio: ratio, rank: e.key + 1, isFirst: e.key == 0),
            ); 
          }),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final TopMenuItem item;
  final int rank;
  final double ratio;
  final bool isFirst;
  const _MenuItemTile({
    required this.item,
    required this.ratio,
    required this.rank,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isFirst ? _gold : _green2.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('#$rank',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: isFirst ? _white : _green2)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _green1)),
                Text('${item.price}  ·  ${item.sold} sold',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        color: _green1.withOpacity(0.5))),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (_, box) => Stack(children: [
          Container(
              height: 4,
              width: box.maxWidth,
              decoration: BoxDecoration(
                  color: _green2.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10))),
          Container(
              height: 4,
              width: box.maxWidth * ratio,
              decoration: BoxDecoration(
                  color: isFirst ? _gold : _green2.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10))),
        ])),
      ],
    );
  }
}