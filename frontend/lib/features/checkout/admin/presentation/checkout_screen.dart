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
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OrderSummary(
                            orderItems: widget.orderItems,
                            subtotal: subtotal,
                            total: total,
                            orderType: widget.orderType,
                            isStacked: true,
                          ),
                          const SizedBox(height: 20),
                          _buildPaymentEntry(formattedOrderNumber, true),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 4, 
                            child: OrderSummary(
                              orderItems: widget.orderItems,
                              subtotal: subtotal,
                              total: total,
                              orderType: widget.orderType,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 6, 
                            child: _buildPaymentEntry(formattedOrderNumber, false),
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

  Widget _buildPaymentEntry(String formattedOrderNumber, bool isStacked) {
    return PaymentEntry(
      total: total,
      change: change,
      isStacked: isStacked,
      onCashChanged: (value) => setState(() => cashGiven = value),
      orderItems: widget.orderItems,
      onSubmit: (int selectedMethod) async {
        
        String paymentMethodStr = "CASH";
        PaymentMethod receiptMethod = PaymentMethod.cash;
        
        if (selectedMethod == 1) {
          paymentMethodStr = "CARD";
          receiptMethod = PaymentMethod.card;
        } else if (selectedMethod == 2) {
          paymentMethodStr = "E-WALLET";
          receiptMethod = PaymentMethod.gcash; 
        }

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
          paymentMethod: paymentMethodStr, 
          paymentStatus: "PAID",
          customerName: "WALK-IN CUSTOMER",
          customerPhone: "N/A",
          notes: "N/A",
          items: databaseItems,
        );

        bool success = await OrderService().createOrder(orderRequest);

        if (!mounted) return;

        if (success) {
          OrderType parsedOrderType = OrderType.walkIn;
          if (widget.orderType.toLowerCase().contains("dine")) parsedOrderType = OrderType.dineIn;
          if (widget.orderType.toLowerCase().contains("take")) parsedOrderType = OrderType.takeOut;

          final receiptData = ReceiptData(
            orderNumber: formattedOrderNumber,
            clientName: "WALK-IN CUSTOMER",
            dateTime: DateTime.now(),
            orderType: parsedOrderType,
            paymentMethod: receiptMethod,
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
              content: const Text('Failed to process payment.', style: TextStyle(fontWeight: FontWeight.w600)), 
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.15), // Subtle, soft border line
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 24),
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Checkout",
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary, 
                    fontSize: 28, 
                    fontWeight: FontWeight.w900,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  "Finalize transaction and payment",
                  style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.w500, fontSize: 13)
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