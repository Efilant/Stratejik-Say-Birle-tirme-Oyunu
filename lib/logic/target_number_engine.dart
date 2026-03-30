import 'dart:math';
import '../models/block.dart';

/// Meryem · Üye 3 (Vize Madde 4): Hedef sayı üretim motoru.
///
/// Hedef sayı rastgele seçilir; ancak öncelik mevcut griddeki 2-4 blokluk
/// komşu zincirlerden üretilebilen toplamlar arasından seçim yapmaktır.
/// Böylece üretilen hedeflerin oynanabilir olma olasılığı yükselir.
class TargetNumberEngine {
  TargetNumberEngine._();

  static const List<List<int>> _dirs = <List<int>>[
    <int>[-1, -1],
    <int>[-1, 0],
    <int>[-1, 1],
    <int>[0, -1],
    <int>[0, 1],
    <int>[1, -1],
    <int>[1, 0],
    <int>[1, 1],
  ];

  static int generateTarget({
    required List<List<Block?>> grid,
    required Random rnd,
    required int minSelectionCount,
    required int maxSelectionCount,
    required int minTargetSum,
    required int maxTargetSum,
  }) {
    final possible = _collectPossibleSums(
      grid: grid,
      minSelectionCount: minSelectionCount,
      maxSelectionCount: maxSelectionCount,
      minTargetSum: minTargetSum,
      maxTargetSum: maxTargetSum,
    );

    if (possible.isEmpty) {
      return minTargetSum + rnd.nextInt(maxTargetSum - minTargetSum + 1);
    }

    final list = possible.toList(growable: false);
    return list[rnd.nextInt(list.length)];
  }

  static Set<int> _collectPossibleSums({
    required List<List<Block?>> grid,
    required int minSelectionCount,
    required int maxSelectionCount,
    required int minTargetSum,
    required int maxTargetSum,
  }) {
    final rows = grid.length;
    if (rows == 0) return <int>{};
    final cols = grid[0].length;
    final sums = <int>{};

    bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;
    int idx(int r, int c) => r * cols + c;

    void dfs(int r, int c, int depth, int sum, Set<int> visited) {
      final current = grid[r][c];
      if (current == null) return;

      final nextDepth = depth + 1;
      final nextSum = sum + current.value;

      if (nextDepth >= minSelectionCount &&
          nextDepth <= maxSelectionCount &&
          nextSum >= minTargetSum &&
          nextSum <= maxTargetSum) {
        sums.add(nextSum);
      }
      if (nextDepth == maxSelectionCount) return;

      for (final d in _dirs) {
        final nr = r + d[0];
        final nc = c + d[1];
        if (!inBounds(nr, nc) || grid[nr][nc] == null) continue;

        final k = idx(nr, nc);
        if (visited.contains(k)) continue;

        visited.add(k);
        dfs(nr, nc, nextDepth, nextSum, visited);
        visited.remove(k);
      }
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (grid[r][c] == null) continue;
        final visited = <int>{idx(r, c)};
        dfs(r, c, 0, 0, visited);
      }
    }
    return sums;
  }
}
