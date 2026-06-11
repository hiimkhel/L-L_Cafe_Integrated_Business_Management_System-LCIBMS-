import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import '../widgets/order_summary.dart';
import '../widgets/payment_entry.dart';
import 'package:frontend/core/widgets/receipt.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/core/models/order_request.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_queue_screen.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final String orderType;
  final int orderOrderId;

  const CheckoutConfirmationScreen({
    super.key, 
    required this.orderType, 
    required this.orderItems, 
    required this.orderOrderId
  });

  @override
  State<CheckoutConfirmationScreen> createState() => _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState extends State<CheckoutConfirmationScreen>{
  double cashGiven = 0;

  double get subtotal => widget.orderItems.fold(
    0,
    (sum, item) => sum + (item["price"] * item["qty"]),
  );

  double get total => subtotal;
  double get change => cashGiven - total;
  bool get isPaymentValid => cashGiven >= total;

  @override
  Widget build(BuildContext context) {
    final String formattedOrderNumber = "WALK-${widget.orderOrderId.toString().padLeft(5, '0')}";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive threshold: 850px width
                if (constraints.maxWidth < 850) {
                  // Stack vertically for smaller/narrower screens
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OrderSummary(
                          orderItems: widget.orderItems,
                          subtotal: subtotal,
                          total: total,
                          orderType: widget.orderType
                        ),
                        SizedBox(
                          height: 600, // Ensure PaymentEntry has bounded height
                          child: _buildPaymentEntry(formattedOrderNumber),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Side-by-side for widescreen monitors
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4, 
                        child: OrderSummary(
                          orderItems: widget.orderItems,
                          subtotal: subtotal,
                          total: total,
                          orderType: widget.orderType
                        )
                      ),
                      Expanded(
                        flex: 6, 
                        child: _buildPaymentEntry(formattedOrderNumber)
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentEntry(String formattedOrderNumber) {
    return PaymentEntry(
      total: total,
      change: change,
      onCashChanged: (value) => setState(() => cashGiven = value),
      orderItems: widget.orderItems,
      onSubmit: () async {
        final databaseItems = widget.orderItems.map((item) {
          return {
            "menu_item_id": item["id"],
            "name": item["name"],
            "quantity": item["qty"],
            "unit_price": item["price"],
            "subtotal": (item["price"] as double) * (item["qty"] as int),
          };
        }).toList();

        final orderRequest = OrderRequest(
          orderNumber: formattedOrderNumber,
          source: "POS",
          orderType: widget.orderType,
          subtotal: subtotal,
          deliveryFee: 0.0,
          total: total,
          paymentMethod: "CASH", 
          paymentStatus: "PAID",
          customerName: "WALK-IN CUSTOMER",
          customerPhone: "N/A",
          notes: "N/A",
          items: databaseItems,
        );

        bool success = await OrderService().createOrder(orderRequest);

        if (success) {
          final receiptData = ReceiptData(
            orderNumber: formattedOrderNumber,
            clientName: "WALK-IN CUSTOMER",
            dateTime: DateTime.now(),
            orderType: OrderType.walkIn,
            paymentMethod: PaymentMethod.cash,
            items: widget.orderItems.map((item) {
              return OrderItem(
                name: item["name"],
                quantity: item["qty"],
                unitPrice: item["price"],
              );
            }).toList(),
          );
          if(context.mounted) _showReceipt(context, receiptData);
        } else {
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to process payment. Please try again.'), backgroundColor: Colors.redAccent)
            );
          }
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CHECKOUT CONFIRMATION",
                style: AppTextStyles.title.copyWith(color: AppColors.secondary, fontSize: 24)
              ),
              Text(
                "FINAL PHASE OF TRANSACTION",
                style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.w600)
              ),
            ],
          ),
        ],
      )
    );
  }

  void _showReceipt(BuildContext context, ReceiptData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: LLCafeReceipt(
            data: data,
            onPrint: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OrderQueueScreen()),
                (route) => false, 
              );
            },
          ),
        );
      }
    );
  }
}