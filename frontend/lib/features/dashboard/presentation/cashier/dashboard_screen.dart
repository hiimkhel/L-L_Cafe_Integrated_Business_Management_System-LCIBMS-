import 'package:flutter/material.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_queue_screen.dart';

class PosDashboardScreen extends StatelessWidget {
  const PosDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: Center(
        // this button handle naviagtion to order queue screen
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderQueueScreen(),
              ),
            );
          },
          child: const Text('Go to Order Queue'),
        ),
      ),
    );
  }
}