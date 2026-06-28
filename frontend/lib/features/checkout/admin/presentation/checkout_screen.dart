import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import '../widgets/order_summary.dart';
import '../widgets/payment_entry.dart';
import 'package:frontend/core/widgets/receipt.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/core/models/order_request.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_queue_screen.dart';
import 'package:frontend/core/models/receipt_model.dart';
import 'package:frontend/core/services/pos/print_services.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/services/pos/native_printer_services.dart';
import 'package:frontend/core/models/flavor_models.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final String orderType;
  final int orderOrderId;
  

  const CheckoutConfirmationScreen({
    super.key,
    required this.orderType,
    required this.orderItems,
    required this.orderOrderId,
  });

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  double cashGiven = 0;

  double get subtotal => widget.orderItems.fold(
        0.0,
        (sum, item) =>
            sum +
            ((item["price"] as num).toDouble() *
                (item["qty"] as num).toInt()),
      );

  double get total => subtotal;
  double get change => cashGiven - total;

  @override
  Widget build(BuildContext context) {
    final String formattedOrderNumber =
        "WALK-${widget.orderOrderId.toString().padLeft(5, '0')}";

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 24.0),
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
                            child: _buildPaymentEntry(
                                formattedOrderNumber, false),
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
          final receiptData = ReceiptData(
            orderNumber: formattedOrderNumber,
            clientName: "WALK-IN CUSTOMER",
            dateTime: DateTime.now(),
            orderType: OrderType.walkIn,
            paymentMethod: receiptMethod,
            items: widget.orderItems.map((item) {
              return OrderItem(
                name: item["name"],
                quantity: item["qty"],
                unitPrice: (item["price"] as num).toDouble(),

                variantCategory: item["variant_category"],

                variantName: item["variant_name"],

                flavors: item["flavors"] != null
                    ? (item["flavors"] as List<Flavor>)
                        .map((f) => f.flavorName)
                        .toList()
                    : const [],
              );
            }).toList(),
            cashReceived: cashGiven,
            change: change,
          );

          _showReceipt(context, receiptData);
          await NativePrinterService.printTest();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Failed to save order to database")),
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CHECKOUT CONFIRMATION",
                style: AppTextStyles.title.copyWith(color: AppColors.secondary),
              ),
              Text(
                "FINAL PHASE OF TRANSACTION",
                style: AppTextStyles.body.copyWith(color: AppColors.tertiary),
              ),
            ],
          ),
        ],
      ),
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
            onPrint: () async {
              final navigator = Navigator.of(context);

              try {
                print("STARTING PRINT");

                navigator.pop();

                await Future.delayed(const Duration(milliseconds: 100));

                await PrintService.printReceipt(data);

                print("PRINT FINISHED");
              } catch (e) {
                print("PRINT ERROR: $e");
              }

              // ALWAYS go to queue screen (even if print fails)
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => OrderQueueScreen()),
                (route) => false,
              );
            },
          ),
        );
      },
    );
  }
}