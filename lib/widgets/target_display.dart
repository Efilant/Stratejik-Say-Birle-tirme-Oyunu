import 'package:flutter/material.dart';

///Üye 4 · Sude : Hedef Sayı göstergesi.
class TargetDisplay extends StatelessWidget {
  final int target;

  const TargetDisplay({super.key, this.target = 7});

  @override
  Widget build(BuildContext context) {
    const Color neonYellow = Color(0xFFFFD600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: neonYellow,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: neonYellow.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Hedef: $target',
        style: const TextStyle(
          color: Color(0xFF0D0033),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
