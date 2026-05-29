import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 3. görev kişisi meryem — Final Aşaması Madde 5:
/// shared_preferences içinde tutulan tek bir skor kaydını temsil eder.
class ScoreEntry {
  final int score;
  final DateTime playedAt;

  const ScoreEntry({required this.score, required this.playedAt});

  Map<String, dynamic> toJson() => {
        'score': score,
        'playedAt': playedAt.toIso8601String(),
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        score: json['score'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}

/// 3. görev kişisi meryem — Final Aşaması Madde 5:
/// Skoru [SharedPreferences]'a kaydeder ve listeyi yüksekten düşüğe döndürür.
class ScoreRepository {
  static const String _key = 'leaderboard_scores';
  static const int _maxStored = 100;

  /// Yeni skoru kaydeder.
  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAll(prefs);
    entries.add(ScoreEntry(score: score, playedAt: DateTime.now()));
    entries.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = entries.take(_maxStored).toList();
    await prefs.setString(
        _key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  /// Kayıtlı skorları yüksekten düşüğe döndürür.
  static Future<List<ScoreEntry>> loadScores({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAll(prefs);
    if (limit != null && entries.length > limit) {
      return entries.sublist(0, limit);
    }
    return entries;
  }

  static Future<List<ScoreEntry>> _loadAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final entries = list
          .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => b.score.compareTo(a.score));
      return entries;
    } catch (_) {
      return [];
    }
  }

  /// Tüm skorları siler.
  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
