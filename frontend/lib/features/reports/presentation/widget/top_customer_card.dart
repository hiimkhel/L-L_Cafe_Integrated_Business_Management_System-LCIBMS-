import 'package:flutter/material.dart';
import './base_card.dart';

const Color _primary = Color(0xFF3D5A45);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);
const Color _muted   = Color(0xFF8A8070);

class TopCustomersCard extends StatelessWidget {
  final List<dynamic> customers;
    final VoidCallback? onViewAll;

  const TopCustomersCard({
    required this.customers,
    this.onViewAll
  });

  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      try{
        return BaseCard(
          title: 'TOP CUSTOMERS',
            trailing: GestureDetector(
              onTap: onViewAll,
              child: _pill('ALL', _primary),
            ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 42,
                  color: _muted,
                ),
                SizedBox(height: 12),
                Text(
                  'No customer purchases found',
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
      }catch (e, stack) {
        print(e);
        print(stack);

        return const Center(
          child: Text('Error loading customers'),
        );
      }
     
    }

    return BaseCard(
      title: 'TOP CUSTOMERS',
      trailing: GestureDetector(
        onTap: onViewAll,
        child: _pill('ALL', _primary),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: customers.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final customer = customers[i];

          final String customerName =
              customer['customer_name'] ??
              'Unknown Customer';

          final String profilePicture =
              customer['profile_picture'] ?? '';

          final double amount =
              double.tryParse(
                    customer['total_spent'].toString(),
                  ) ??
                  0;

          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [

                _rankBadge(i + 1),

                const SizedBox(width: 10),

                _buildAvatar(
                  customerName,
                  profilePicture,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: _dark,
                        ),
                      ),

                      const SizedBox(height: 2),
                    ],
                  ),
                ),

                Text(
                  '₱${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: _gold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildAvatar(
    String customerName,
    String profilePicture,
  ) {
    if (profilePicture.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(profilePicture),
        backgroundColor: Colors.grey.shade200,
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: _primary.withOpacity(0.12),
      child: Text(
        getInitials(customerName),
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: _primary,
        ),
      ),
    );
  }

  Widget _rankBadge(int rank) {
    return SizedBox(
      width: 24,
      child: Text(
        '#$rank',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: _primary,
        ),
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