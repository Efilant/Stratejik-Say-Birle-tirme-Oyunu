import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_over_screen.dart';
import '../widgets/score_board.dart';
import '../widgets/target_display.dart';

/// [Elif], [Esma] ve [Sude] iş birliğiyle hazırlanan ana oyun ekranı.
/// Ekran yerleşimi (Elif), hamle onay ve Snackbar geri bildirimleri (Esma)
/// ve son görsel UI düzenlemeleri (Sude) bu birimde gerçekleştirilmiştir.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameEngine(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Stratejik Sayı Birleştirme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<GameEngine>(
                              builder: (_, engine, __) =>
                                  TargetDisplay(target: engine.targetSum),
                            ),
                            Consumer<GameEngine>(
                              builder: (_, engine, __) =>
                                  ScoreBoard(score: engine.score),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Center(child: GameGrid()),
                        const SizedBox(height: 8),
                        _buildBottomControls(context),
                      ],
                    ),
                  ),
                  // Oyun Sonu Overlay — Madde 4
                  const GameOverOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Alt kısımdaki butonları ve uyarı metnini oluşturan metod
  Widget _buildBottomControls(BuildContext context) {
    return Consumer<GameEngine>(
      builder: (context, engine, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bilgilendirme Metni
            if (engine.selectedPath.length < GameEngine.minSelectionCount)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Hamle için en az ${GameEngine.minSelectionCount} blok seçin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            // Butonlar Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassButton(
                  label: 'Temizle',
                  onPressed:
                      engine.selectedPath.isEmpty || engine.isResolvingExplosion
                          ? null
                          : () => engine.clearSelection(),
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(width: 16),
                _buildGlassButton(
                  label: 'Onayla',
                  onPressed: engine.selectedPath.length <
                              GameEngine.minSelectionCount ||
                          engine.isResolvingExplosion
                      ? null
                      : () => onConfirmMoveTap(context, engine),
                  color: const Color(0xFF00D2FF).withOpacity(0.8),
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Oyunu Bitir butonu
            _buildEndGameButton(
              onPressed: engine.isResolvingExplosion
                  ? null
                  : () => _confirmEndGame(context, engine),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  /// Oyunu Bitir butonu
  static Widget _buildEndGameButton({required VoidCallback? onPressed}) {
    return Opacity(
      opacity: onPressed == null ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_rounded,
                  color: Colors.redAccent.withOpacity(0.85), size: 16),
              const SizedBox(width: 6),
              Text(
                'Oyunu Bitir',
                style: TextStyle(
                  color: Colors.redAccent.withOpacity(0.85),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Onay dialog'u — yanlışlıkla basımı önler.
  static Future<void> _confirmEndGame(
      BuildContext context, GameEngine engine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1F6F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Oyunu Bitir?',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: Text(
          'Mevcut skorun kaydedilecek ve oyun sona erecek.',
          style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Vazgeç',
                style: TextStyle(color: Colors.white.withOpacity(0.55))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bitir',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) engine.endGame();
  }

  /// Ortak Tasarımlı Cam Buton Oluşturucu
  static Widget _buildGlassButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              if (isPrimary && onPressed != null)
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Esma · Üye 2: Onayla — Logic ve Feedback Sistemi
void onConfirmMoveTap(BuildContext context, GameEngine engine) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  if (engine.selectedPath.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(
          content: Text('Önce blok seçin.'), duration: Duration(seconds: 2)),
    );
    return;
  }

  switch (engine.validateMoveSelection()) {
    case MoveSelectionValidation.tooFewBlocks:
      messenger.showSnackBar(
        SnackBar(
            content: Text(
                'En az ${GameEngine.minSelectionCount} blok seçmelisiniz.')),
      );
      return;
    case MoveSelectionValidation.tooManyBlocks:
      messenger.showSnackBar(
        SnackBar(
            content: Text(
                'En fazla ${GameEngine.maxSelectionCount} blok seçebilirsiniz.')),
      );
      return;
    case MoveSelectionValidation.invalidNeighborChain:
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Seçim geçerli bir komşu zinciri oluşturmuyor.')),
      );
      return;
    case MoveSelectionValidation.ok:
      switch (engine.submitMove()) {
        case SubmitMoveResult.invalidSelection:
          messenger
              .showSnackBar(const SnackBar(content: Text('Seçim geçersiz.')));
          return;
        case SubmitMoveResult.wrongSum:
          messenger.showSnackBar(
              const SnackBar(content: Text('Toplam hedef sayıya eşit değil.')));
          return;
        case SubmitMoveResult.explosionStarted:
          // Madde 7: Bloklar parlar ve süre sonunda yok olur
          Future<void>.delayed(GameEngine.explosionEffectDuration, () {
            if (!context.mounted) return;
            engine.completeExplosionAfterAnimation();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            final breakdown = engine.lastMoveScoreBreakdown;
            final detail = breakdown.isNotEmpty ? ' ($breakdown)' : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hedef tuttu! +${engine.lastSubmittedMoveGain} puan$detail',
                ),
                backgroundColor: const Color(0xFF00E676),
                duration: const Duration(seconds: 2),
              ),
            );
          });
          return;
      }
  }
}
