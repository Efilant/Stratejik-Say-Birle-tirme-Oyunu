import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/block.dart';

/// Düşen blok - col ve anlık row ile takip edilir (UI için)
class FallingBlock {
  final int col;
  double row;
  final int value;

  FallingBlock({required this.col, required this.row, required this.value});
}

/// Üye 1 - Grid & Mekanik: 8x10 matris, düşme ve tabana yerleşme
/// author: Elif
class GameEngine extends ChangeNotifier {
  static const int rows = 10;
  static const int cols = 8;
  static const int initialFilledRows = 3;
  static const Duration fallInterval = Duration(milliseconds: 500);
  static const Duration spawnInterval = Duration(seconds: 5);

  final List<List<Block?>> _grid = List.generate(rows, (_) => List.filled(cols, null));
  final List<FallingBlock> _fallingBlocks = [];
  Timer? _fallTimer;
  Timer? _spawnTimer;
  final Random _rnd = Random();

  List<List<Block?>> get grid => _grid;
  List<FallingBlock> get fallingBlocks => List.unmodifiable(_fallingBlocks);

  GameEngine() {
    _initGrid();
    _startTimers();
    _spawnNewRow(); // Oyun başında hemen blok düşsün
  }

  /// Başlangıç: alt 3 satır (7,8,9) dolu - üst boş kalır, bloklar düşebilir
  void _initGrid() {
    for (int r = rows - initialFilledRows; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _grid[r][c] = Block(value: _rnd.nextInt(9) + 1, row: r, col: c);
      }
    }
  }

  void _startTimers() {
    _fallTimer = Timer.periodic(fallInterval, (_) => _onFallTick());
    _spawnTimer = Timer.periodic(spawnInterval, (_) => _spawnNewRow());
  }

  /// Her 500ms: düşen blokları bir birim aşağı kaydır, yerleşenleri gride al
  void _onFallTick() {
    bool changed = false;
    final toSettle = <FallingBlock>[];

    for (final fb in _fallingBlocks) {
      final nextRow = fb.row + 1;
      final canFall = nextRow < rows && _grid[nextRow.toInt()][fb.col] == null;
      if (canFall) {
        fb.row = nextRow;
        changed = true;
      } else {
        toSettle.add(fb);
      }
    }

    for (final fb in toSettle) {
      _settleBlock(fb);
      _fallingBlocks.remove(fb);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Blok tabana veya başka bloğun üstüne yerleşir
  void _settleBlock(FallingBlock fb) {
    final r = fb.row.toInt().clamp(0, rows - 1);
    if (r < rows && _grid[r][fb.col] == null) {
      _grid[r][fb.col] = Block(value: fb.value, row: r, col: fb.col);
    }
  }

  /// Her 5 sn: sütun boşsa ve düşen blok yoksa yeni blok ekle
  void _spawnNewRow() {
    final fallingCols = _fallingBlocks.map((fb) => fb.col).toSet();
    for (int c = 0; c < cols; c++) {
      if (_grid[0][c] == null && !fallingCols.contains(c)) {
        _fallingBlocks.add(FallingBlock(
          col: c,
          row: -1,
          value: _rnd.nextInt(9) + 1,
        ));
      }
    }
    notifyListeners();
  }

  void dispose() {
    _fallTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }
}
