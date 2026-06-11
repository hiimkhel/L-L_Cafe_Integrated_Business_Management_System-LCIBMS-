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

  // Safe arithmetic processing for JSON objects
  double get subtotal => widget.orderItems.fold(
    0.0,
    (sum, item) => sum + ((item["price"] as num).toDouble() * (item["qty"] as num).toInt()),
  );

  double get total => subtotal;
  double get change => cashGiven - total;

  @override
  Widget build(BuildContext context) {
    final String formattedOrderNumber = "WALK-${widget.orderOrderId.toString().padLeft(5, '0')}";

    return Scaffold(
      backgroundColor: AppColors.background, 
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: LayoutBuilder(
                builder: (constraintsContext, constraints) {
                  final bool isTablet = constraints.maxWidth >= 900;
                  
                  if (!isTablet) {
                    // Modern Fluid Mobile View (Scrollable & Spaced)
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: OrderSummary(
                              orderItems: widget.orderItems,
                              subtotal: subtotal,
                              total: total,
                              orderType: widget.orderType,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: _buildPaymentEntry(formattedOrderNumber),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Ultra-Modern Split Monitor View for POS
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5, 
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.tertiary.withOpacity(0.08)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.03),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: OrderSummary(
                                  orderItems: widget.orderItems,
                                  subtotal: subtotal,
                                  total: total,
                                  orderType: widget.orderType,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6, 
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.tertiary.withOpacity(0.08)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.03),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: _buildPaymentEntry(formattedOrderNumber),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
          final price = (item["price"] as num).toDouble();
          final qty = (item["qty"] as num).toInt();
          return {
            "menu_item_id": item["id"],
            "name": item["name"],
            "quantity": qty,
            "unit_price": price,
            "subtotal": price * qty,
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

        if (!mounted) return;

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
                quantity: (item["qty"] as num).toInt(),
                unitPrice: (item["price"] as num).toDouble(),
              );
            }).toList(),
          );
          _showReceipt(context, receiptData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to process payment. Please try again.'), 
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      color: Colors.transparent,
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            shadowColor: AppColors.primary.withOpacity(0.1),
            elevation: 2,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.tertiary.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Checkout Confirmation",
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary, 
                    fontSize: 26, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5
                  )
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "POS SYSTEM",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 10,
                          letterSpacing: 1.0
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "FINAL PHASE OF TRANSACTION",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.tertiary.withOpacity(0.8), 
                        fontWeight: FontWeight.w700, 
                        fontSize: 11, 
                        letterSpacing: 0.5
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  void _showReceipt(BuildContext parentContext, ReceiptData data) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: LLCafeReceipt(
            data: data,
            onPrint: () {
              final navigator = Navigator.of(parentContext);
              Navigator.pop(dialogContext); 
              navigator.pushAndRemoveUntil(
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