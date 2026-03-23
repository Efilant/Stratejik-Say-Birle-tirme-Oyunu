/// Liderlik tablosu için skor modeli (Final aşamasında kullanılacak)
class ScoreEntry {
  final String playerName;
  final int score;
  final DateTime date;

  const ScoreEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });
}
