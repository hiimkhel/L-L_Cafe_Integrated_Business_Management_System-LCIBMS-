import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import "package:frontend/config/theme/app_text_styles.dart";

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState
    extends State<DeliveryDashboardScreen> {
  String selectedFilter = "ALL";

  final List<Map<String, dynamic>> orders = [
    {
      "id": "LL-145",
      "name": "Maria Santos",
      "address": "123 Mabini St, Makati City",
      "time": "10:30 AM",
      "items": "3 ITEMS",
      "status": "PREPARING"
    },
    {
      "id": "LL-146",
      "name": "Juan Dela Cruz",
      "address": "456 Rizal Ave, Pasig City",
      "time": "10:45 AM",
      "items": "5 ITEMS",
      "status": "OUT FOR DELIVERY"
    },
    {
      "id": "LL-147",
      "name": "Anna Reyes",
      "address": "789 Bonifacio St, QC",
      "time": "11:00 AM",
      "items": "2 ITEMS",
      "status": "PREPARING"
    },
    {
      "id": "LL-148",
      "name": "Carlos Mendoza",
      "address": "321 Luna St, Mandaluyong",
      "time": "11:15 AM",
      "items": "4 ITEMS",
      "status": "OUT FOR DELIVERY"
    },
    {
      "id": "LL-144",
      "name": "Sofia Garcia",
      "address": "654 Del Pilar St, Taguig",
      "time": "10:15 AM",
      "items": "4 ITEMS",
      "status": "DELIVERED"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 HEADER
            _buildHeader(),

            const SizedBox(height: 16),

            // 🔹 SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Search orders...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 FILTER BUTTONS
            Row(
              children: [
                _filterBtn("ALL"),
                _filterBtn("PREPARING"),
                _filterBtn("OUT FOR DELIVERY"),
              ],
            ),

            const SizedBox(height: 8),

            _filterBtn("DELIVERED", fullWidth: true),

            const SizedBox(height: 12),

            // 🔹 ORDER LIST
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  if (selectedFilter != "ALL" &&
                      order["status"] != selectedFilter) {
                    return const SizedBox();
                  }

                  return _orderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(){
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        child: Row(children: [
          
            const SizedBox(width: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DELIVERY PANEL",
                  style: AppTextStyles.title.copyWith(color: AppColors.secondary),
                ),
                Text(
                  "DELIVERY ORDER MANAGEMENT",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.tertiary,
                  )
                ),
              ],
            ),

            const Spacer(),

            Row(children: [
              Column(children: [
                Text("ACTIVE", 
                  style: AppTextStyles.title.copyWith(
                    fontSize: 10,
                    color: AppColors.tertiary,
                )),
                Text("4", 
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.secondary,
                  )
                )
              ],
            ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.secondary,
                  size: 30
                )
              )

            ],)
        ],)
        
      );
    }

  // 🔹 FILTER BUTTON
  Widget _filterBtn(String label, {bool fullWidth = false}) {
    final isSelected = selectedFilter == label;

    return Expanded(
      flex: fullWidth ? 1 : 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 ORDER CARD
  Widget _orderCard(Map<String, dynamic> order) {
    Color statusColor;

    switch (order["status"]) {
      case "PREPARING":
        statusColor = Colors.orange;
        break;
      case "OUT FOR DELIVERY":
        statusColor = Colors.blue;
        break;
      case "DELIVERED":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order["id"],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order["status"],
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          Text(order["name"],
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 4),

          Text(order["address"],
              style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order["time"]),
              Text(order["items"]),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 16),
              )
            ],
          )
        ],
      ),
    );
  }
}