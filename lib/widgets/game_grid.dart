import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import 'block_widget.dart';

/// 8x10 oyun alanı — temel grid: Üye 1 · Elif.
/// Dokunmatik seçim, patlama hücresi, Snackbar geri bildirimi: Üye 2 · Esma.
class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  void _feedbackSelection(BuildContext context, SelectionTapResult r) {
    String? msg;
    switch (r) {
      case SelectionTapResult.rejectedNotAdjacent:
        msg = 'Sadece komşu bloklar seçilebilir (yatay, dikey, çapraz).';
        break;
      case SelectionTapResult.rejectedMaxLength:
        msg = 'En fazla ${GameEngine.maxSelectionCount} blok seçebilirsiniz.';
        break;
      case SelectionTapResult.rejectedEmpty:
      case SelectionTapResult.extended:
      case SelectionTapResult.shortened:
      case SelectionTapResult.cleared:
        return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

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
                  final sel = engine.isCellSelected(row, col);
                  return Material(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: block == null || engine.isResolvingExplosion
                          ? null
                          : () {
                              final result = engine.onCellTapped(row, col);
                              _feedbackSelection(context, result);
                            },
                      child: Center(
                        child: block != null
                            ? BlockWidget(
                                value: block.value,
                                size: cellSize - 4,
                                selected: sel,
                                exploding: engine.isCellExploding(row, col),
                                explosionKey: engine.isCellExploding(row, col)
                                    ? '${engine.explosionAnimGen}-$row-$col'
                                    : null,
                                explosionDuration:
                                    GameEngine.explosionEffectDuration,
                              )
                            : null,
                      ),
                    ),
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
