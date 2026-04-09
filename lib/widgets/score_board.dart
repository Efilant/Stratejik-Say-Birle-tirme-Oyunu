import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';

/// [Sude] tarafından hazırlanan puan tablosu ve oyun sıfırlama bileşeni.
/// Mevcut puan durumunu, hata sayacını ve yeni oyun butonunu içerir.
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
            fontSize: 20, // Font boyutunu küçülttük
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8), // Boşluğu azalttık
        // Hata Sayacı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Paddingi daralttık
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Text(
            'Hata: ${engine.wrongMoveCount}/3',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12, // Font boyutunu küçülttük
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8), // Boşluğu azalttık
        GestureDetector(
          onTap:
              engine.isResolvingExplosion ? null : () => engine.restartGame(),
          child: Container(
            padding: const EdgeInsets.all(8), // İkon paddingini azalttık
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
              size: 20, // İkon boyutunu küçülttük
            ),
          ),
        ),
      ],
    );
  }
}
