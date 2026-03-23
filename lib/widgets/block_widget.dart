import 'package:flutter/material.dart';
import '../models/block.dart';
import '../utils/color_constants.dart';

/// Sayıya göre renklendirilmiş blok (Üye 4 - renk paleti)
/// author: Elif
class BlockWidget extends StatelessWidget {
  final int value;
  final Color? color;
  final double size;

  const BlockWidget({
    super.key,
    required this.value,
    this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? blockColors[value] ?? Colors.grey;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: const Offset(1, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
