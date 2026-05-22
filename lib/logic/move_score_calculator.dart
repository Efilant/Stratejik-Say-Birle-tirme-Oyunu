import '../utils/digit_scores.dart';

/// [Esma] · Final Madde 2 (PDF Bölüm 5 — Puan Hesaplama).
/// Doğru hamle sonrası: Toplam Puan = seçilen blokların puan değerlerinin toplamı.
class MoveScoreCalculator {
  MoveScoreCalculator._();

  /// Tek bir blok değerinin sabit puan karşılığı (1→1 … 9→20).
  static int pointsForBlockValue(int value) => DigitScores.pointsFor(value);

  /// Patlayan / seçilen blok değerlerinin hamle puanını hesaplar.
  static int totalForValues(Iterable<int> values) {
    var total = 0;
    for (final value in values) {
      total += pointsForBlockValue(value);
    }
    return total;
  }

  /// Geri bildirim için kırılım metni: "3+7+9 = 19"
  static String formatBreakdown(List<int> values) {
    if (values.isEmpty) return '0';
    final parts = values.map((v) => pointsForBlockValue(v).toString()).join('+');
    return '$parts = ${totalForValues(values)}';
  }
}
