import 'package:flutter/material.dart';
import '../utils/color_constants.dart';

/// [Elif] tarafından hazırlanan oyun bloğu modeli.
/// Sayı değerini, grid üzerindeki konumunu ve renk bilgilerini taşır.
class Block {
  final int value;
  final int row;
  final int col;

  const Block({
    required this.value,
    required this.row,
    required this.col,
  });

  Color get color => AppColors.blockColors[value] ?? Colors.grey;

  Color get glowColor => AppColors.getGlowColor(value);

  Block copyWith({int? value, int? row, int? col}) => Block(
        value: value ?? this.value,
        row: row ?? this.row,
        col: col ?? this.col,
      );
}
