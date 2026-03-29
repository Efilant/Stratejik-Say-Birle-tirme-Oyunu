import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/color_constants.dart';

/// Renkli blok görünümü — Üye 1 · Elif (temel kutu + sayı).
/// Seçim çerçevesi ve patlama animasyonu — Üye 2 · Esma.
/// UI Düzenlemeleri — Üye 4 · Sude.
class BlockWidget extends StatelessWidget {
  final int? value;
  final double size;
  final bool isSelected;
  final bool isExploding; // Madde 7 için yeni
  final bool isError; // Madde 8 için yeni
  final VoidCallback? onTap;

  const BlockWidget({
    super.key,
    this.value,
    this.size = 45,
    this.isSelected = false,
    this.isExploding = false,
    this.isError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return _buildEmptyTile();

    final color = AppColors.blockColors[value] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        // Patlıyorsa daha fazla büyür, seçiliyse normal büyür
        scale: isExploding ? 1.25 : (isSelected ? 1.1 : 1.0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isExploding)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 25,
                  spreadRadius: 4,
                ),

              if (isError)
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              // Normal Seçim Parlaması
              if (isSelected && !isExploding && !isError)
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Seçim/Hata Çerçevesi (Ring Effect)
              if (isSelected || isError)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isError ? Colors.redAccent : Colors.white,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),

              // Ana Cam Gövdesi
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      // Patlıyorsa beyaza, hata varsa kırmızıya döner
                      color: isExploding
                          ? Colors.white
                          : (isError
                              ? Colors.red.withOpacity(0.8)
                              : color.withOpacity(0.9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(isSelected ? 0.6 : 0.3),
                        width: 2.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Yansıma Efekti
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white
                                      .withOpacity(isExploding ? 0.8 : 0.4),
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
                            style: TextStyle(
                              // Patlama anında sayı rengi kendi rengine döner
                              color: isExploding ? color : Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                if (!isExploding)
                                  const Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                              ],
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
