import 'package:flutter/material.dart';
import '../utils/color_constants.dart';

/// Renkli blok görünümü — Üye 1 · Elif (temel kutu + sayı).
/// Seçim çerçevesi ve patlama animasyonu — Üye 2 · Esma.
class BlockWidget extends StatelessWidget {
  final int value;
  final Color? color;
  final double size;

  /// Seçim zincirinde mi — Madde 5 görsel geri bildirim (Üye 2)
  final bool selected;

  /// Hedef tutunca patlama animasyonu
  final bool exploding;

  /// Patlayan hücre için benzersiz anahtar (ör. 'gen-row-col')
  final String? explosionKey;

  final Duration explosionDuration;

  const BlockWidget({
    super.key,
    required this.value,
    this.color,
    this.size = 36,
    this.selected = false,
    this.exploding = false,
    this.explosionKey,
    this.explosionDuration = const Duration(milliseconds: 420),
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? blockColors[value] ?? Colors.grey;
    final core = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
        border:
            selected ? Border.all(color: Colors.amberAccent, width: 3) : null,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$value',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );

    if (!exploding) return core;

    // Esma: ölçek + soluklaşma (patlama)
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(explosionKey ?? 'pop-$value'),
      tween: Tween(begin: 0, end: 1),
      duration: explosionDuration,
      curve: Curves.easeIn,
      builder: (context, t, child) {
        final scale = 1.0 + 0.65 * t;
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: 1.0 - t, child: child),
        );
      },
      child: core,
    );
  }
}
