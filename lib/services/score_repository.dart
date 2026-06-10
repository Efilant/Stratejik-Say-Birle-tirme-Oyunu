import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Meryem — shared_preferences içinde tutulan skor kaydı (oyuncu adı + puan).
class ScoreEntry {
  final String playerName;
  final int score;
  final DateTime playedAt;

  const ScoreEntry({
    required this.playerName,
    required this.score,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'playedAt': playedAt.toIso8601String(),
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        playerName: (json['playerName'] as String?)?.trim().isNotEmpty == true
            ? (json['playerName'] as String).trim()
            : 'Oyuncu',
        score: json['score'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}

/// Meryem — Skoru [SharedPreferences]'a kaydeder ve sıralı listeyi döndürür.
class ScoreRepository {
  static const String _key = 'leaderboard_scores';
  static const int _maxStored = 100;

  /// Meryem — Oyuncu adı ile yeni skoru kaydeder.
  static Future<void> saveScore({
    required String playerName,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAll(prefs);
    entries.add(ScoreEntry(
      playerName: playerName.trim(),
      score: score,
      playedAt: DateTime.now(),
    ));
    entries.sort(_compareByScoreDesc);
    final trimmed = entries.take(_maxStored).toList();
    await prefs.setString(
        _key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  /// Meryem — Oyun sonu için: puana göre yüksekten düşüğe.
  static Future<List<ScoreEntry>> loadScores({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAll(prefs);
    entries.sort(_compareByScoreDesc);
    if (limit != null && entries.length > limit) {
      return entries.sublist(0, limit);
    }
    return entries;
  }

  static int _compareByScoreDesc(ScoreEntry a, ScoreEntry b) {
    return b.score.compareTo(a.score);
  }

  static Future<List<ScoreEntry>> _loadAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
          .toList();
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
