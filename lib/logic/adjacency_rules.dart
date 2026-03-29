import '../models/grid_pos.dart';

/// Üye 2 — Esma: blok seçim kuralları — komşuluk algoritması (PDF Madde 6).
///
/// PDF Madde 3–4: yatay, dikey ve çapraz komşuluk (8 yön, kendisi hariç).
/// Bu dosya sadece geometrik kuralı içerir; UI veya oyun döngüsü bilmez.
class AdjacencyRules {
  AdjacencyRules._();

  /// İki hücre komşu mu? (Chebyshev mesafesi 1: paylaşılan kenar veya köşe)
  static bool areNeighbors(int r1, int c1, int r2, int c2) {
    final dr = (r1 - r2).abs();
    final dc = (c1 - c2).abs();
    if (dr == 0 && dc == 0) return false;
    return dr <= 1 && dc <= 1;
  }

  /// PDF: "Seçilen bloklar bir seçim zinciri oluşturur" — ardışık her çift komşu,
  /// aynı blok iki kez yok. Hamle onayı (hedef toplam) burada değil; sadece komşuluk.
  static bool isValidNeighborChain(List<GridPos> path) {
    if (path.length < 2) return false;
    final seen = <GridPos>{};
    for (var i = 0; i < path.length; i++) {
      final p = path[i];
      if (!seen.add(p)) return false;
      if (i > 0) {
        final q = path[i - 1];
        if (!areNeighbors(p.row, p.col, q.row, q.col)) return false;
      }
    }
    return true;
  }
}
