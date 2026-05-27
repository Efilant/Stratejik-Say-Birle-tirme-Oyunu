import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/color_constants.dart';

/// Sude - Patlama animasyonu olan blok.
class ExplodingBlockWidget extends StatefulWidget {
  final int value;
  final double size;

  /// Animasyon tamamlandığında çağrılır (isteğe bağlı — sadece bilgilendirme).
  final VoidCallback? onDone;

  const ExplodingBlockWidget({
    super.key,
    required this.value,
    required this.size,
    this.onDone,
  });

  @override
  State<ExplodingBlockWidget> createState() => _ExplodingBlockWidgetState();
}

class _ExplodingBlockWidgetState extends State<ExplodingBlockWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Flash fazı (0→0.25): blok beyaza döner
  late final Animation<double> _flashAnim;
  // Scale fazı (0→0.65): büyür
  late final Animation<double> _scaleAnim;
  // Fade fazı (0.45→1.0): solar
  late final Animation<double> _fadeAnim;
  // Parçacık fazı (0.30→1.0): kıvılcımlar yayılır
  late final Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _flashAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.45)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.45, end: 1.65)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(_ctrl);

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );

    _particleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward().whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.blockColors[widget.value] ?? Colors.grey;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final flash = _flashAnim.value; // 0→1 hızla
        final scale = _scaleAnim.value; // 1→1.65
        final fade = 1.0 - _fadeAnim.value; // 1→0 (opaklık)
        final particle = _particleAnim.value; // 0→1

        // Flash ilerledikçe renk beyaza kayar
        final blockColor = Color.lerp(color, Colors.white, flash)!;

        return SizedBox(
          // Parçacıkların taşması için blok boyutunun 3 katı alan
          width: widget.size * 3,
          height: widget.size * 3,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Parçacık katmanı ──────────────────────────────────────
              if (particle > 0)
                CustomPaint(
                  size: Size(widget.size * 3, widget.size * 3),
                  painter: _ParticlePainter(
                    progress: particle,
                    color: color,
                    blockSize: widget.size,
                  ),
                ),

              // ── Glow halkası ──────────────────────────────────────────
              if (fade > 0)
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.6 * fade),
                          blurRadius: widget.size * 1.2,
                          spreadRadius: widget.size * 0.4,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4 * fade),
                          blurRadius: widget.size * 0.6,
                          spreadRadius: widget.size * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Ana blok gövdesi ──────────────────────────────────────
              if (fade > 0)
                Opacity(
                  opacity: fade.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9 * fade),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: (1.0 - flash * 2).clamp(0.0, 1.0),
                          child: Text(
                            '${widget.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
// Parçacık Painter
// ---------------------------------------------------------------------------

class _ParticlePainter extends CustomPainter {
  final double progress; // 0→1
  final Color color;
  final double blockSize;

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.blockSize,
  });

  // Sabit tohum — her frame'de aynı açılar oluşsun
  static const List<_ParticleDef> _defs = [
    // Ana parçacıklar (8 yön)
    _ParticleDef(angle: 0, size: 1.0, speed: 1.0, type: _PType.spark),
    _ParticleDef(angle: 45, size: 0.8, speed: 0.85, type: _PType.spark),
    _ParticleDef(angle: 90, size: 1.0, speed: 1.0, type: _PType.spark),
    _ParticleDef(angle: 135, size: 0.8, speed: 0.90, type: _PType.spark),
    _ParticleDef(angle: 180, size: 1.0, speed: 0.95, type: _PType.spark),
    _ParticleDef(angle: 225, size: 0.8, speed: 0.85, type: _PType.spark),
    _ParticleDef(angle: 270, size: 1.0, speed: 1.0, type: _PType.spark),
    _ParticleDef(angle: 315, size: 0.8, speed: 0.90, type: _PType.spark),
    // Ara açı parçacıklar (daha küçük)
    _ParticleDef(angle: 22, size: 0.5, speed: 1.2, type: _PType.dot),
    _ParticleDef(angle: 67, size: 0.5, speed: 1.1, type: _PType.dot),
    _ParticleDef(angle: 112, size: 0.5, speed: 1.2, type: _PType.dot),
    _ParticleDef(angle: 157, size: 0.5, speed: 1.15, type: _PType.dot),
    _ParticleDef(angle: 202, size: 0.5, speed: 1.2, type: _PType.dot),
    _ParticleDef(angle: 247, size: 0.5, speed: 1.1, type: _PType.dot),
    _ParticleDef(angle: 292, size: 0.5, speed: 1.2, type: _PType.dot),
    _ParticleDef(angle: 337, size: 0.5, speed: 1.15, type: _PType.dot),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = blockSize * 1.25;

    for (final def in _defs) {
      final t = (progress * def.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      // Hız eğrisi: başta hızlı, sonda yavaş (yerçekimi etkisi)
      final easedT = Curves.easeOut.transform(t);
      final radius = maxRadius * easedT;

      final rad = def.angle * (pi / 180.0);
      final dx = cos(rad) * radius;
      final dy = sin(rad) * radius;
      final pos = center + Offset(dx, dy);

      // Opaklık: erken parlak, sonra solar
      final opacity = (1.0 - easedT * 0.85).clamp(0.0, 1.0);

      if (def.type == _PType.spark) {
        _drawSpark(canvas, pos, def, opacity, rad, easedT);
      } else {
        _drawDot(canvas, pos, def, opacity);
      }
    }
  }

  void _drawSpark(Canvas canvas, Offset pos, _ParticleDef def, double opacity,
      double angleRad, double t) {
    final paint = Paint()
      ..color = Color.lerp(Colors.white, color, t * 0.7)!.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Kıvılcım: ince uzun elips, hareket yönüne dönük
    final sparkLength = blockSize * 0.28 * def.size;
    final sparkWidth = blockSize * 0.07 * def.size;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angleRad);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: sparkLength, height: sparkWidth),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.restore();
  }

  void _drawDot(Canvas canvas, Offset pos, _ParticleDef def, double opacity) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, blockSize * 0.045 * def.size, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

enum _PType { spark, dot }

class _ParticleDef {
  final double angle; // derece
  final double size; // göreli boyut çarpanı
  final double speed; // göreli hız çarpanı
  final _PType type;

  const _ParticleDef({
    required this.angle,
    required this.size,
    required this.speed,
    required this.type,
  });
}
