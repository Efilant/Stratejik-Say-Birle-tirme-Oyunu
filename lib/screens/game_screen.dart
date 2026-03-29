import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_engine.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_board.dart';
import '../widgets/target_display.dart';

/// Ana oyun ekranı: layout — Elif; Provider, onay, Snackbar, yeni oyun — Esma · Üye 2.
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
              title: const Text('Stratejik Sayı Birleştirme'),
              centerTitle: true,
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              actions: [
                Consumer<GameEngine>(
                  builder: (ctx, engine, __) => IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Yeni oyun',
                    onPressed: engine.isResolvingExplosion
                        ? null
                        : () {
                            engine.restartGame();
                            ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                          },
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 24),
                    const Center(child: GameGrid()),
                    const SizedBox(height: 16),
                    Consumer<GameEngine>(
                      builder: (context, engine, _) {
                        return Column(
                          children: [
                            if (engine.selectedPath.length == 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Hamle için en az ${GameEngine.minSelectionCount}, en fazla ${GameEngine.maxSelectionCount} blok seçin.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                              ),
                            FilledButton(
                              onPressed: engine.isResolvingExplosion
                                  ? null
                                  : () => onConfirmMoveTap(context, engine),
                              child: const Text('Onayla'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Esma · Üye 2: Onayla — 2–4 blok, komşu zincir, hedef kontrolü, patlama sonrası mesaj.
void onConfirmMoveTap(BuildContext context, GameEngine engine) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  if (engine.selectedPath.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Önce blok seçin.'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  switch (engine.validateMoveSelection()) {
    case MoveSelectionValidation.tooFewBlocks:
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Tek hamlede en az ${GameEngine.minSelectionCount} blok seçmelisiniz.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    case MoveSelectionValidation.tooManyBlocks:
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Tek hamlede en fazla ${GameEngine.maxSelectionCount} blok seçebilirsiniz.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    case MoveSelectionValidation.invalidNeighborChain:
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Seçim geçerli bir komşu zinciri oluşturmuyor.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    case MoveSelectionValidation.ok:
      switch (engine.submitMove()) {
        case SubmitMoveResult.invalidSelection:
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Seçim geçersiz.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        case SubmitMoveResult.wrongSum:
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Yanlış seçim: seçilen blokların toplamı hedef sayıya eşit değil.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        case SubmitMoveResult.explosionStarted:
          Future<void>.delayed(GameEngine.explosionEffectDuration, () {
            if (!context.mounted) return;
            engine.completeExplosionAfterAnimation();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hedef tuttu! +${engine.lastSubmittedMoveGain} puan',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          });
          return;
      }
  }
}
