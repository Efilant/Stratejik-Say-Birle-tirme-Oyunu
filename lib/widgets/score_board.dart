import 'package:flutter/material.dart';

/// Puan göstergesi (Final'da puan hesaplaması entegre edilecek)
/// author: Elif
class ScoreBoard extends StatelessWidget {
  final int score;

  const ScoreBoard({super.key, this.score = 0});

  @override
  Widget build(BuildContext context) {
    return Text('Puan: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
