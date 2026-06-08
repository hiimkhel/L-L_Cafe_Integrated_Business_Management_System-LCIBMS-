import 'package:flutter/material.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold = Color(0xFFA98258);
const Color _beige = Color(0xFFEFE2C9);
const Color _white = Colors.white;

Future<double?> showSetTargetDialog(
  BuildContext context,
  double currentTarget,
) async {
  final ctrl = TextEditingController(
    text: currentTarget.toStringAsFixed(0),
  );

  return showDialog<double>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: _beige,
      title: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _green2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'SET DAILY TARGET',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: _green1,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your daily revenue target (₱):',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              color: _green1.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₱ ',
              filled: true,
              fillColor: _white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            final val =
                double.tryParse(ctrl.text.replaceAll(',', ''));

            Navigator.pop(ctx, val);
          },
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
}