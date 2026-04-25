import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/dashboard/presentation/rider/dashboard_screen.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const DeliveryDetailsScreen({super.key, required this.order});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  //---------------------------------delivery status color-----------------------------------------------
  bool isStepActive(String step) {
    final status = widget.order["status"];

    const steps = ["PREPARING", "READY", "OUT FOR DELIVERY", "DELIVERED"];

    final currentIndex = steps.indexOf(status);
    final stepIndex = steps.indexOf(step);

    return stepIndex <= currentIndex;
  }

  Color getColor(String step) {
    return isStepActive(step)
        ? AppColors
            .secondary // ACTIVE (green)
        : AppColors.primary.withOpacity(0.5); // INACTIVE
  }

  Color getIconColor(String step) {
    return isStepActive(step)
        ? AppColors.white // ACTIVE (green)
        : AppColors.primary.withOpacity(0.5); // INACTIVE
  }

  Color getBoxColor(String step) {
    return isStepActive(step)
        ? AppColors.secondary // ACTIVE (green)
        : AppColors.white; // INACTIVE
  }

  Icon getStatusIcon(String step) {
    return isStepActive(step) 
    ? Icon(Icons.check_circle_outline, color: AppColors.secondary)
    : Icon(Icons.check_circle_outline, color: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            _deliveryHeader(),
            Divider(thickness: 1, color: AppColors.primary),
            const SizedBox(height: 10),
            _customer(),
            const SizedBox(height: 7),
            _customerDetails(),
            const SizedBox(height: 15),
            _order(),
            const SizedBox(height: 7),
            _orderDetails(),
            const SizedBox(height: 15),
            _progress(),
            const SizedBox(height: 7),
            _progressDetails(),
            const SizedBox(height: 15),
            _markReady(),
            const SizedBox(height: 15),
            _contactCustomer(),
            const SizedBox(height: 15),
            _reportIssue(),
          ],
        ),
      ),
    );
  }

  Widget _deliveryHeader() {
    Color statusColor;

    switch (widget.order["status"]) {
      case "PREPARING":
        statusColor = AppColors.preparingColor;
        break;
      case "OUT FOR DELIVERY":
        statusColor = AppColors.deliveringColor;
        break;
      case "DELIVERED":
        statusColor = AppColors.deliveredColor;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 20, 15, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.receiptDark.withOpacity(.5),
                    offset: Offset(0, 4),
                    blurRadius: 3,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: AppColors.primary, size: 19),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            children: [
              Text(
                'DETAILS',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
              Text(
                'ORDER ${widget.order["id"]}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.7,
                ),
              ),
            ],
          ),
          const Spacer(),

          SizedBox(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.receiptDark.withOpacity(.5),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 15,
                    color: AppColors.white.withOpacity(0.4),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.order["status"]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        children: [
          SizedBox(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person_2_outlined,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Text(
            'CUSTOMER',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.receiptDark,
              letterSpacing: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(.5),
            offset: Offset(1, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_2_outlined,
                  color: AppColors.secondary,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),

                  Text(
                    '${widget.order['name']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.receiptDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.call_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),

                  Text(
                    '+${widget.order['phone'] ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.receiptDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.receiptBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.place_outlined,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADDRESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),

                  Text(
                    '+${widget.order['address'] ?? 'N/A'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.receiptDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.secondary,
                      size: 23,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NOTES',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Customer notes wdwud wjdhwud',
                      style: TextStyle(
                        color: AppColors.receiptDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _order() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        children: [
          SizedBox(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Text(
            'ORDER',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.receiptDark,
              letterSpacing: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderDetails() {
    final List items = widget.order['order'] ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(.5),
            offset: Offset(1, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                color: AppColors.secondary,
                size: 26,
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.order['time']}',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Divider(thickness: 1, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 7),

          ...List.generate(items.length, (index) {
            final item = items[index] as Map<String, dynamic>;
            return Row(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Text(
                  item['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),

                Text(
                  '₱${item['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 7),
          Divider(thickness: 1, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 7),

          Builder(
            builder: (_) {
              final deliveryFee = 50.00;

              final double subtotal = items.fold(
                0.0,
                (sum, item) => sum + (item as Map<String, dynamic>)['price'],
              );

              final orderTotal = subtotal + deliveryFee;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'SUBTOTAL',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),

                      Text(
                        '₱${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        'DELIVERY FEE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),

                      Text(
                        '₱${deliveryFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Divider(
                    thickness: 1,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 7),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),

                      Text(
                        '${orderTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        children: [
          SizedBox(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Text(
            'PROGRESS',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.receiptDark,
              letterSpacing: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressDetails() {
    final step1 = "PREPARING";
    final step2 = "READY";
    final step3 = "OUT FOR DELIVERY";
    final step4 = "DELIVERED";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(.5),
            offset: Offset(1, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: getBoxColor(step1),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.5),
                      offset: Offset(0, 4),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: getIconColor(step1),
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),

              Text(
                step1,
                style: TextStyle(
                  color: getColor(step1),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              getStatusIcon(step1),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: getBoxColor(step2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.5),
                      offset: Offset(0, 4),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: getIconColor(step2),
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),

              Text(
                step2,
                style: TextStyle(
                  color: getColor(step2),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              getStatusIcon(step2),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: getBoxColor(step3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.5),
                      offset: Offset(0, 4),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: getIconColor(step3),
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),

              Text(
                step3,
                style: TextStyle(
                  color: getColor(step3),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              getStatusIcon(step3),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: getBoxColor(step4),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.5),
                      offset: Offset(0, 4),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: getIconColor(step4),
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),

              Text(
                step4,
                style: TextStyle(
                  color: getColor(step4),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              getStatusIcon(step4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _markReady() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          boxShadow: [
            BoxShadow(
              color: AppColors.receiptDark,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'MARK AS READY',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _contactCustomer() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.receiptDark,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'CONTACT CUSTOMER',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _reportIssue() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.receiptDark,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'REPORT ISSUE',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
