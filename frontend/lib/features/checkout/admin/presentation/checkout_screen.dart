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
import 'package:frontend/core/services/pos/print_bridge_service.dart';


class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key, required this.orderType, required this.orderItems, required this.orderOrderId});

  // Expected data from order_entry.dart screen
  final List<Map<String, dynamic>> orderItems;
  final String orderType;
  final int orderOrderId;
  

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
          body: Column(children: [
              _buildHeader(),
              Expanded(child: Row(children: [
                Expanded(flex: 4, child: OrderSummary(
                  orderItems: widget.orderItems,
                  subtotal: subtotal,
                  total: total,
                  orderType: widget.orderType
                )),
                Expanded(flex: 6, child: PaymentEntry(
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
                    // 1. Prepare the OrderRequest for the Database/API
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
                      customerPhone: "09xxxxxxxxx",
                      notes: "N/A",
                      items: databaseItems,
                    );

                    // 2. Call the API
                    bool success = await OrderService().createOrder(orderRequest);

                    if (success) {
                      // 3. Prepare data for the Visual Receipt
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
                        cashReceived: cashGiven,
                        change: change
                      );

                      // 4. Show the receipt only after successful DB entry
                      _showReceipt(context, receiptData);
                      await NativePrinterService.printTest();
                    } else {
                      // Handle error (show a SnackBar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to save order to database")),
                      );
                    }
                  },
                )
              ),
              ],),)
          ],
        )
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
          Container(
            decoration: BoxDecoration(
              
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 32
              ),

            ),
          ),

          const SizedBox(width: 15),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CHECKOUT CONFIRMATION",
              style: AppTextStyles.title.copyWith(color: AppColors.secondary)
            ),
            Text(
              "FINAL PHASE OF TRANSACTION",
              style: AppTextStyles.body.copyWith(
                color: AppColors.tertiary,
              )
            ),
          ],
        ),
        ],)
        
      );
    }
  }

 

 void _showReceipt(BuildContext context, ReceiptData data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: LLCafeReceipt(
            data: data,
            onPrint: () async {
              final navigator = Navigator.of(context);

              try {
                print("STARTING PRINT");

                // optional: close dialog first
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
            }
          ),
        );
      },
    );
  }