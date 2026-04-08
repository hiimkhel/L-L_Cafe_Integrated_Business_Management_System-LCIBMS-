import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});


  @override
  State<CheckoutConfirmationScreen> createState() => _CheckoutConfirmationScreenState();

}
  class _CheckoutConfirmationScreenState extends State<CheckoutConfirmationScreen>{

    // TEMPORARY VALUES
    final List<Map<String, dynamic>> orderItems = [
      {"name": "Chicken Burger", "qty": 1, "price": 180.00},
      {"name": "S'more", "qty": 1, "price": 165.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
    ];

    double cashGiven = 0;

    double get subtotal =>
        orderItems.fold(0, (sum, item) => sum + item["price"]);

    double get tax => subtotal * 0.12;

    double get total => subtotal + tax;

    double get change => cashGiven - total;
     @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(children: [
            _buildHeader(),
            Expanded(child: Row(children: [
              Expanded(child: _buildOrderSummary()),
              Expanded(child: _buildPaymentEntry()),
            ],),)
        ],)
      );
    }

    Widget _buildHeader(){
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
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
                color: AppColors.tertiary,
              ),

            ),
          ),

          const SizedBox(width: 10),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "CHECKOUT CONFIRMATION",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              "FINAL PHASE OF TRANSACTION",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
        ],)
        
      );
    }

   Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 🔥 OUTSIDE HEADER
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "ORDER SUMMARY",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🧾 CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  // 🔥 Scrollable Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // 🔢 Numbering
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${index + 1}"),
                              ),

                              const SizedBox(width: 10),

                              Expanded(child: Text(item["name"])),

                              Text(
                                "₱${item["price"].toStringAsFixed(2)}",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  _priceRow("Subtotal", 485),
                  _priceRow("Tax (12%)", 58.20),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "GRAND TOTAL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₱543.20",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
   }

  Widget _buildPaymentEntry() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 1️⃣ HEADER INSIDE CARD
            const Text(
              "PAYMENT ENTRY",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // 💳 2️⃣ PAYMENT METHODS (WITH ICONS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _paymentMethodCard(
                  label: "Cash",
                  icon: Icons.payments,
                  selected: true,
                ),
                _paymentMethodCard(
                  label: "Card",
                  icon: Icons.credit_card,
                  selected: false,
                ),
                _paymentMethodCard(
                  label: "E-Wallet",
                  icon: Icons.account_balance_wallet,
                  selected: false,
                ),
              ],
            ),

            const SizedBox(height: 15),

            // 3️⃣ Amount Input
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount Received (₱)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  cashGiven = double.tryParse(value) ?? 0;
                });
              },
            ),

            const SizedBox(height: 10),

            // 4️⃣ Quick Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [100, 200, 500, 1000]
                  .map(
                    (amount) => ElevatedButton(
                      onPressed: () {
                        setState(() {
                          cashGiven = amount.toDouble();
                        });
                      },
                      child: Text("₱$amount"),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            // 5️⃣ Exact Amount
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    cashGiven = total;
                  });
                },
                child: Text(
                  "Exact Amount (₱${total.toStringAsFixed(2)})",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 6️⃣ Change Display
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: change >= 0
                    ? Colors.green[100]
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "CHANGE: ₱${change.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),

            const Spacer(),

            // 7️⃣ Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: change < 0 ? null : () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
                child: const Text("CONFIRM PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  


    // =============== HELLPER FUNCTIONS =========================
    Widget _priceRow(String label, double value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("₱${value.toStringAsFixed(2)}"),
        ],
      );
    }

     Widget _paymentMethodCard({
      required String label,
      required IconData icon,
      required bool selected,
    }) {
      return Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? Colors.blue : Colors.black54,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

  }

 
