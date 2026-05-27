import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import '../services/score_repository.dart';

/// [Sude] Oyun sonu overlay'i.
/// Skoru kaydeder ve kart içinde en yüksek 5 skoru gösterir.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _scoreSaved = false;
  Future<List<ScoreEntry>>? _topScoresFuture;

  static String _levelLabel(int score) {
    if (score < 50) return 'Seviye 1';
    if (score < 150) return 'Seviye 2';
    if (score < 300) return 'Seviye 3';
    if (score < 500) return 'Seviye 4';
    return 'Seviye 5';
  }

  Future<List<ScoreEntry>> _saveAndLoad(int score) async {
    if (!_scoreSaved) {
      _scoreSaved = true;
      await ScoreRepository.saveScore(score);
    }
    return ScoreRepository.loadScores(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (context, engine, _) {
        if (!engine.isGameOver) {
          _scoreSaved = false;
          _topScoresFuture = null;
          return const SizedBox.shrink();
        }

        _topScoresFuture ??= _saveAndLoad(engine.score);

        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 400),
          child: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.65)),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _GameOverCard(
                    score: engine.score,
                    levelLabel: _levelLabel(engine.score),
                    topScoresFuture: _topScoresFuture!,
                    onRestart: () => engine.restartGame(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _GameOverCard extends StatelessWidget {
  final int score;
  final String levelLabel;
  final Future<List<ScoreEntry>> topScoresFuture;
  final VoidCallback onRestart;

  const _GameOverCard({
    required this.score,
    required this.levelLabel,
    required this.topScoresFuture,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B3FBF), Color(0xFF3A2B8F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 8,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF7B5FFF).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Başlık ──────────────────────────────────────────────────────
          const Text(
            'Oyun Bitti!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Final Puanı ──────────────────────────────────────────────────
          Text(
            'Final Puanı',
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: const TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            levelLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // ── En İyi 5 Skor ────────────────────────────────────────────────
          _TopScoresSection(
              topScoresFuture: topScoresFuture, currentScore: score),

          const SizedBox(height: 24),

          // ── Tekrar Oyna ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C6FF).withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Tekrar Oyna',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TopScoresSection extends StatelessWidget {
  final Future<List<ScoreEntry>> topScoresFuture;
  final int currentScore;

  const _TopScoresSection({
    required this.topScoresFuture,
    required this.currentScore,
  });

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFFFD600), size: 16),
            const SizedBox(width: 6),
            Text(
              'En İyi 5 Skor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.80),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Ayırıcı çizgi
        Divider(color: Colors.white.withOpacity(0.10), height: 1),
        const SizedBox(height: 10),

        // Liste
        FutureBuilder<List<ScoreEntry>>(
          future: topScoresFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD600),
                  ),
                ),
              );
            }
            final scores = snap.data ?? [];
            if (scores.isEmpty) {
              return Text(
                'Henüz kayıt yok.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              );
            }
            return Column(
              children: List.generate(scores.length, (i) {
                final entry = scores[i];
                final isCurrentGame = entry.score == currentScore;
                final medal = i < 3 ? _medals[i] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      // Sıra / madalya
                      SizedBox(
                        width: 28,
                        child: medal != null
                            ? Text(medal,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15))
                            : Text(
                                '${i + 1}.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(width: 6),

                      // Skor çubuğu arkaplanı
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCurrentGame
                                ? const Color(0xFFFFD600).withOpacity(0.15)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentGame
                                  ? const Color(0xFFFFD600).withOpacity(0.45)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // "Bu oyun" etiketi
                              if (isCurrentGame)
                                Text(
                                  'Bu oyun',
                                  style: TextStyle(
                                    color: const Color(0xFFFFD600)
                                        .withOpacity(0.80),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Text(
                                  _relativeDate(entry.playedAt),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.40),
                                    fontSize: 11,
                                  ),
                                ),

                              // Puan
                              Text(
                                '${entry.score}',
                                style: TextStyle(
                                  color: isCurrentGame
                                      ? const Color(0xFFFFD600)
                                      : Colors.white.withOpacity(0.85),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  static String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours < 1) return '${diff.inMinutes} dk önce';
    if (diff.inDays < 1) return '${diff.inHours} sa önce';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}';
  }
}
