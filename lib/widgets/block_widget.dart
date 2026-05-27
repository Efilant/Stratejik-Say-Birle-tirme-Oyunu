import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/color_constants.dart';

/// [Elif], [Esma] ve [Sude] iş birliğiyle hazırlanan görsel blok bileşeni.
/// Patlama animasyonu artık [ExplodingBlockWidget] tarafından yönetilmektedir.
class BlockWidget extends StatelessWidget {
  final int? value;
  final double size;

  /// Eğer seçiliyse, seçili sıra (0-based). null ise seçili değil.
  final int? selectedIndex;
  final bool isError;
  final VoidCallback? onTap;

  const BlockWidget({
    super.key,
    this.value,
    this.size = 45,
    this.selectedIndex,
    this.isError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return _buildEmptyTile();

    final color = AppColors.blockColors[value] ?? Colors.grey;
    final bool isSelected = selectedIndex != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isSelected ? 1.10 : 1.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isError)
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              if (isSelected && !isError)
                BoxShadow(
                  color: color.withOpacity(0.75),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Seçim/Hata çerçevesi
              if (isSelected || isError)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isError ? Colors.redAccent : Colors.white,
                        width: isSelected ? 3.0 : 2.5,
                      ),
                    ),
                  ),
                ),

              // Ana cam gövdesi
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isError
                          ? Colors.red.withOpacity(0.8)
                          : color.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            Colors.white.withOpacity(isSelected ? 0.8 : 0.35),
                        width: 2.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Yansıma efekti
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Sayı
                        Center(
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Seçim sırası rozeti
                        if (isSelected)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6),
                                border:
                                    Border.all(color: Colors.white, width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: Text(
                                '${selectedIndex! + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTile() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }
}
