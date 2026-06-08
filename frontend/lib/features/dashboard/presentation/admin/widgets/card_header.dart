import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold   = Color(0xFFA98258);
const Color _beige  = Color(0xFFEFE2C9);
const Color _white  = Colors.white;
const Color _dark   = Color(0xFF2D2A26);



class CardHeader extends StatelessWidget {
  final String title;
  const CardHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 4, height: 20,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_green2, _green1]),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 9),
      Text(title,
          style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: _green1)),
    ]);
  }
}