import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';

///Üye 4 · Sude : Puan ve Yeni Oyun butonu.
class ScoreBoard extends StatelessWidget {
  final int score;

  const ScoreBoard({super.key, this.score = 0});

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<GameEngine>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Puan Metni
        Text(
          'Puan: $score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap:
              engine.isResolvingExplosion ? null : () => engine.restartGame(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
