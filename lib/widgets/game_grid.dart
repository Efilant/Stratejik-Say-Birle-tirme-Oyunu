import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import 'block_widget.dart';
import 'exploding_block_widget.dart';

/// 8x10 oyun alanı — temel grid: Üye 1 · Elif.
/// Dokunmatik seçim, patlama hücresi, Snackbar geri bildirimi: Üye 2 · Esma.
/// Son UI düzenlemeleri, kayma hatası düzeltmesi: Üye 4 · Sude.
/// Patlama parçacık animasyonu eklendi: Üye 4 · Sude.
class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (context, engine, _) {
        return LayoutBuilder(builder: (context, constraints) {
          const double spacing = 3.0;

          final screenHeight = MediaQuery.of(context).size.height;
          final maxHeightForGrid = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : screenHeight * 0.85;

          final maxWidth = constraints.maxWidth;

          final cellWidth =
              (maxWidth - (GameEngine.cols - 1) * spacing) / GameEngine.cols;
          final cellHeight =
              (maxHeightForGrid - (GameEngine.rows - 1) * spacing) /
                  GameEngine.rows;

          final baseCell = cellWidth < cellHeight ? cellWidth : cellHeight;
          const shrinkFactor = 0.88;
          final cellSize = baseCell * shrinkFactor;
          final gridWidth =
              GameEngine.cols * cellSize + (GameEngine.cols - 1) * spacing;
          final gridHeight =
              GameEngine.rows * cellSize + (GameEngine.rows - 1) * spacing;

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              // Patlama parçacıkları hücre sınırını taşabilir; overflow görünür kalsın
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── 1. KATMAN: Boş arka plan kareleri ────────────────────
                  ...List.generate(GameEngine.rows * GameEngine.cols, (i) {
                    final row = i ~/ GameEngine.cols;
                    final col = i % GameEngine.cols;
                    return Positioned(
                      left: col * (cellSize + spacing),
                      top: row * (cellSize + spacing),
                      child: BlockWidget(value: null, size: cellSize),
                    );
                  }),

                  // ── 2. KATMAN: Sabit bloklar ──────────────────────────────
                  for (int r = 0; r < GameEngine.rows; r++)
                    for (int c = 0; c < GameEngine.cols; c++)
                      if (engine.grid[r][c] != null &&
                          !engine.isCellExploding(r, c))
                        Positioned(
                          key: ValueKey(
                              'static_${r}_${c}_${engine.grid[r][c]!.value}'),
                          left: c * (cellSize + spacing),
                          top: r * (cellSize + spacing),
                          child: GestureDetector(
                            onTap: engine.isResolvingExplosion
                                ? null
                                : () => engine.onCellTapped(r, c),
                            child: Builder(builder: (ctx) {
                              final selIndex = engine.selectedPath
                                  .indexWhere((p) => p.row == r && p.col == c);
                              final int? selectedIndexArg =
                                  selIndex >= 0 ? selIndex : null;
                              return BlockWidget(
                                value: engine.grid[r][c]!.value,
                                size: cellSize,
                                selectedIndex: selectedIndexArg,
                                isError: engine.isShowingError &&
                                    engine.isCellSelected(r, c),
                              );
                            }),
                          ),
                        ),

                  // ── 3. KATMAN: Patlayan bloklar (parçacıklı animasyon) ────
                  // Parçacıklar hücre dışına taşacağından Positioned merkezi
                  // hücrenin ortasına alınır, ExplodingBlockWidget kendi
                  // etrafına 3× boyutluk alan açar.
                  for (int r = 0; r < GameEngine.rows; r++)
                    for (int c = 0; c < GameEngine.cols; c++)
                      if (engine.isCellExploding(r, c) &&
                          engine.grid[r][c] != null)
                        Positioned(
                          key: ValueKey(
                              'explode_${r}_${c}_${engine.explosionAnimGen}'),
                          // Merkezi hücrenin tam ortasına hizala
                          left: c * (cellSize + spacing) -
                              cellSize, // -cellSize: 3× genişlik için offset
                          top: r * (cellSize + spacing) - cellSize,
                          child: ExplodingBlockWidget(
                            value: engine.grid[r][c]!.value,
                            size: cellSize,
                          ),
                        ),

                  // ── 4. KATMAN: Düşen bloklar ──────────────────────────────
                  ...engine.fallingBlocks.where((fb) => fb.row >= 0).map((fb) {
                    return Positioned(
                      key: ValueKey('falling_${fb.id}'),
                      left: fb.col * (cellSize + spacing),
                      top: fb.row * (cellSize + spacing),
                      child: BlockWidget(
                        value: fb.value,
                        size: cellSize,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
