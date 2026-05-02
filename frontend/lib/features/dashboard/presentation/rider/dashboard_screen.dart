import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import "package:frontend/config/theme/app_text_styles.dart";
import 'package:frontend/features/dashboard/presentation/rider/delivery_details.dart';
import 'package:frontend/core/services/rider/order_service.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  String selectedFilter = "ALL";
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  String _mapFilterToStatus(String filter) {
    switch (filter) {
      case "PREPARING": return "preparing";
      case "OUT FOR DELIVERY": return "out_for_delivery";
      case "DELIVERED": return "completed";
      case "READY": return "ready";
      default: return "ready"; 
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    
    // For "ALL", we'll default to 'ready' orders for riders, 
    // or you can fetch multiple statuses.
    String status = _mapFilterToStatus(selectedFilter);
    final data = await _orderService.getRiderOrders(status);
    
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTopSearchRow(),
            const SizedBox(height: 12),
            _buildFilterButtons(), // Refactored below
            const SizedBox(height: 12),
            Divider(color: AppColors.primary, thickness: 1, height: 20),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: _orders.isEmpty 
                      ? const Center(child: Text("No orders found"))
                      : ListView.builder(
                          itemCount: _orders.length,
                          itemBuilder: (context, index) => _orderCard(_orders[index]),
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(child: _filterBtn("READY")),
        const SizedBox(width: 8),
        Expanded(child: _filterBtn("OUT FOR DELIVERY")),
        const SizedBox(width: 8),
        Expanded(child: _filterBtn("DELIVERED")),
      ],
    );
  }

  Widget _filterBtn(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = label);
        _fetchOrders();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.secondary : Colors.black12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9, // Slightly smaller to fit "OUT FOR DELIVERY"
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    // 1. Logic for Status Color (using DB underscores)
    Color statusColor;
    switch (order["status"]) {
      case "preparing": statusColor = AppColors.preparingColor; break;
      case "out_for_delivery": statusColor = AppColors.deliveringColor; break;
      case "completed": statusColor = AppColors.deliveredColor; break;
      case "ready": statusColor = Colors.orange; break;
      default: statusColor = Colors.grey;
    }

    // 2. Format the time (created_at)
    DateTime createdAt = DateTime.tryParse(order["created_at"]?.toString() ?? "") ?? DateTime.now();
    String timeString = "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    "#${order["order_number"]}", // Using order_number from DB
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  order["status"].toString().replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                order["customer_name"] ?? "WALK-IN", // Matched to Backend Key
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.receiptDark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order["delivery_address"] ?? "No address", // Matched to Backend Key
                  style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.primary.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(timeString, style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                  const SizedBox(width: 12),
                  Icon(Icons.inventory_2, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    "${order["items"].length} items", // Counts items in the list
                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryDetailsScreen(order: order, orderId: order["id"]),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 1)),
      ),
      child: Row(
        children: [
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
                style: AppTextStyles.body.copyWith(color: AppColors.tertiary),
              ),
            ],
          ),

          const Spacer(),

          Row(
            children: [
              Column(
                children: [
                  Text(
                    "ACTIVE",
                    style: AppTextStyles.title.copyWith(
                      fontSize: 10,
                      color: AppColors.tertiary,
                    ),
                  ),
                  Text(
                    "4",
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
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
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchRow() {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: TextField(
        style: TextStyle(fontSize: 12, color: AppColors.tertiary),
        decoration: InputDecoration(
          hintText: 'SEARCH CUSTOMER...',
          hintStyle: TextStyle(
            color: AppColors.tertiary.withOpacity(.5),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          suffixIcon: Icon(Icons.search, size: 16, color: AppColors.tertiary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.tertiary.withOpacity(.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.tertiary, width: .9),
          ),
        ),
      ),
    );
  }
}
