import 'package:flutter/material.dart';

import '../services/score_repository.dart';
import '../utils/color_constants.dart';
import 'game_screen.dart';

/// Meryem — Giriş sayfası: oyuncu adı alımı ve skor tablosu önizlemesi.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<List<ScoreEntry>>? _scoresFuture;

  @override
  void initState() {
    super.initState();
    _scoresFuture = ScoreRepository.loadScoresSortedByName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B1134),
              Color(0xFF2D1B69),
              Color(0xFF1A1625),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildNameCard(),
                    const SizedBox(height: 24),
                    _buildLeaderboardCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF7B5FFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B5FFF).withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Stratejik Sayı\nBirleştirme',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Komşu blokları birleştir, hedef sayıya ulaş, puanını yükselt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNameCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded,
                    color: Colors.white.withOpacity(0.7), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Oyuncu Adı',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Adını yaz...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                counterStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF00C6FF),
                    width: 1.5,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Lütfen adını gir.';
                if (trimmed.length < 2) return 'En az 2 karakter olmalı.';
                return null;
              },
              onFieldSubmitted: (_) => _startGame(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _startGame,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C6FF).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Oyuna Başla',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5B3FBF).withOpacity(0.55),
            const Color(0xFF3A2B8F).withOpacity(0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFD600), size: 18),
              const SizedBox(width: 8),
              Text(
                'Skor Tablosu',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'İsme göre',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          const SizedBox(height: 12),
          FutureBuilder<List<ScoreEntry>>(
            future: _scoresFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFD600),
                      ),
                    ),
                  ),
                );
              }
              final scores = snap.data ?? [];
              if (scores.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Henüz kayıt yok. İlk skoru sen yap!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: List.generate(scores.length.clamp(0, 8), (i) {
                  final entry = scores[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${i + 1}.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.playerName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${entry.score}',
                          style: const TextStyle(
                            color: Color(0xFFFFD600),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
