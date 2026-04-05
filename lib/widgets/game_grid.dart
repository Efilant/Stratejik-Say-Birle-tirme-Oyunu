import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import 'block_widget.dart';

/// 8x10 oyun alanı — temel grid: Üye 1 · Elif.
/// Dokunmatik seçim, patlama hücresi, Snackbar geri bildirimi: Üye 2 · Esma.
/// Son UI düzenlemeleri, kayma hatası düzeltmesi: Üye 4 · Sude.
class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (context, engine, _) {
        return LayoutBuilder(builder: (context, constraints) {
          // spacing between cells
          const double spacing = 3.0; // slightly smaller spacing to fit more

          // Use available width to compute cell size. For height, reserve a fraction
          // of screen so grid doesn't overflow other UI. If parent provides tight
          // height constraints, those will be used.
          final screenHeight = MediaQuery.of(context).size.height;
          final maxHeightForGrid = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : screenHeight * 0.85; // increase reserved height so full grid fits

          final maxWidth = constraints.maxWidth;

          final cellWidth = (maxWidth - (GameEngine.cols - 1) * spacing) /
              GameEngine.cols;
          final cellHeight = (maxHeightForGrid -
                  (GameEngine.rows - 1) * spacing) /
              GameEngine.rows;

          // Apply a small global shrink factor so the grid's minimum size is a bit
          // smaller and more likely to fit on smaller screens.
          final baseCell = cellWidth < cellHeight ? cellWidth : cellHeight;
          final shrinkFactor = 0.88; // reduce min height/width slightly
          final cellSize = baseCell * shrinkFactor;
          final gridWidth = GameEngine.cols * cellSize +
              (GameEngine.cols - 1) * spacing;
          final gridHeight = GameEngine.rows * cellSize +
              (GameEngine.rows - 1) * spacing;

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
              child: ClipRect(
                // Üstten taşanları keser
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // 1. KATMAN: Arka Plandaki Boş Kareler (Hizalama Referansı)
                    ...List.generate(GameEngine.rows * GameEngine.cols, (i) {
                      final row = i ~/ GameEngine.cols;
                      final col = i % GameEngine.cols;
                      return Positioned(
                        left: col * (cellSize + spacing),
                        top: row * (cellSize + spacing),
                        child: BlockWidget(value: null, size: cellSize),
                      );
                    }),

                    // 2. KATMAN: Grid'deki Sabit Bloklar (Hücreye Tam Oturanlar)
                    for (int r = 0; r < GameEngine.rows; r++)
                      for (int c = 0; c < GameEngine.cols; c++)
                        if (engine.grid[r][c] != null)
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
                                // Seçili sıra index'ini hesapla (0-based). Eğer seçili değilse null.
                                final selIndex = engine.selectedPath.indexWhere(
                                    (p) => p.row == r && p.col == c);
                                final int? selectedIndexArg =
                                    selIndex >= 0 ? selIndex : null;
                                return BlockWidget(
                                  value: engine.grid[r][c]!.value,
                                  size: cellSize,
                                  selectedIndex: selectedIndexArg,
                                );
                              }),
                            ),
                          ),

                    // 3. KATMAN: Düşen Bloklar
                    ...engine.fallingBlocks.where((fb) => fb.row >= 0).map((fb) {
                      return Positioned(
                        key: ValueKey('falling_${fb.col}_${fb.value}'),
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
            ),
          );
        });
      },
    );
  }
}
