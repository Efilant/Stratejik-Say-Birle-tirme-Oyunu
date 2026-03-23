import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_board.dart';
import '../widgets/target_display.dart';

/// Ana oyun ekranı
/// author: Elif
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stratejik Sayı Birleştirme'),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: ChangeNotifierProvider(
        create: (_) => GameEngine(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    TargetDisplay(target: 9),
                    ScoreBoard(score: 0),
                  ],
                ),
                const SizedBox(height: 24),
                Center(child: GameGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
