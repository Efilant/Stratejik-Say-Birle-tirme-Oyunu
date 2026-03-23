import 'package:flutter/material.dart';

/// Hedef sayı göstergesi (Üye 3 - rastgele hedef entegre edilecek)
/// author: Elif
class TargetDisplay extends StatelessWidget {
  final int target;

  const TargetDisplay({super.key, this.target = 9});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Hedef: $target', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
