import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import 'block_widget.dart';

/// 8x10 oyun alanı - GridView ile matris gösterimi
/// author: Elif
class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (context, engine, _) {
        final grid = engine.grid;
        final falling = engine.fallingBlocks;
        const cellSize = 36.0;

        return SizedBox(
          width: GameEngine.cols * cellSize,
          height: GameEngine.rows * cellSize,
          child: Stack(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: GameEngine.cols,
                  childAspectRatio: 1,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: GameEngine.rows * GameEngine.cols,
                itemBuilder: (context, i) {
                  final row = i ~/ GameEngine.cols;
                  final col = i % GameEngine.cols;
                  final block = grid[row][col];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: block != null
                        ? BlockWidget(value: block.value, size: cellSize - 4)
                        : null,
                  );
                },
              ),
              ...falling.map((fb) {
                final r = fb.row;
                if (r >= GameEngine.rows) return const SizedBox.shrink();
                return Positioned(
                  left: fb.col * cellSize + 2,
                  top: r * cellSize + 2,
                  child: BlockWidget(value: fb.value, size: cellSize - 4),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
