import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../logic/adjacency_rules.dart';
import '../logic/target_number_engine.dart';
import '../models/block.dart';
import '../models/grid_pos.dart';
import '../utils/digit_scores.dart';

// ===========================================================================
// Üye 2 — Esma: seçim sonuç enum'ları, doğrulama, patlama.
// Üye 1 — Elif: 8x10 grid, düşen bloklar, spawn / yerleşme.
// Üye 3 — Meryem: hedef sayı mekanizması (Vize Madde 4) ve hedef üretim sistemi.
// Üye 4 — Sude: Görsel stabilite, hata yönetimi ve kesintisiz oyun akışı.
// ===========================================================================

/// Esma · Üye 2 — dokunma sonucu (SnackBar / seçim geri bildirimi)
enum SelectionTapResult {
  /// Zincire yeni komşu hücre eklendi
  extended,

  /// Zincir kısaltıldı veya son adım geri alındı
  shortened,

  /// Tek seçili hücreye tekrar basıldı, seçim temizlendi
  cleared,

  /// Boş hücre — seçim yok
  rejectedEmpty,

  /// Son seçiliye komşu değil (PDF Madde 4 komşuluk kuralı)
  rejectedNotAdjacent,

  /// En fazla 4 blok (PDF Madde 4)
  rejectedMaxLength,
}

/// Esma · Üye 2 — hamlede 2–4 blok + komşu zincir (PDF)
enum MoveSelectionValidation {
  ok,
  tooFewBlocks,
  tooManyBlocks,
  invalidNeighborChain
}

/// Esma · Üye 2 — onay sonrası hedef / yanlış seçim / patlama aşaması
enum SubmitMoveResult {
  /// Seçim 2–4 veya zincir geçersiz
  invalidSelection,

  /// Toplam hedefe eşit değil — yanlış seçim
  wrongSum,

  /// Patlama animasyonu başladı; süre sonunda [completeExplosionAfterAnimation] çağrılmalı
  explosionStarted,
}

/// Düşen blok - col ve anlık row ile takip edilir (UI için)
class FallingBlock {
  final int col;
  double row;
  final int value;

  /// Sude · Üye 4 — UI'daki milimetrik kaymaları ve key çakışmalarını önlemek için ID.
  final String id;

  FallingBlock({required this.col, required this.row, required this.value})
      : id = DateTime.now().microsecondsSinceEpoch.toString();
}

/// Oyun motoru: Üye 1 (Elif) grid & düşme + Üye 2 (Esma) seçim & hedef hamlesi.
class GameEngine extends ChangeNotifier {
  static const int rows = 10;
  static const int cols = 8;
  static const int initialFilledRows = 3;
  static const Duration fallInterval = Duration(milliseconds: 500);
  static const Duration spawnInterval = Duration(seconds: 5);

  static const int minSelectionCount = 2;
  static const int maxSelectionCount = 4;
  static const Duration explosionEffectDuration = Duration(milliseconds: 420);
  /// Meryem · Üye 3 (Vize Madde 4): en az 2 blok, 1-9 değerler → hedef toplam 2-36.
  static const int minTargetSum = 2;
  static const int maxTargetSum = 36;

  final List<List<Block?>> _grid =
      List.generate(rows, (_) => List.filled(cols, null));
  final List<FallingBlock> _fallingBlocks = [];
  Timer? _fallTimer;
  Timer? _spawnTimer;
  final Random _rnd = Random();

  final List<GridPos> _selectedPath = [];
  int _targetSum = 9;
  int _score = 0;
  int _lastSubmittedMoveGain = 0;
  final List<GridPos> _explosionCells = [];
  int _explosionAnimGen = 0;

  /// Sude · Üye 4 — Madde 8: Toplam tutmadığında blokların kırmızı yanmasını sağlar.
  bool _isShowingError = false;

  List<List<Block?>> get grid => _grid;
  List<FallingBlock> get fallingBlocks => List.unmodifiable(_fallingBlocks);
  List<GridPos> get selectedPath => List.unmodifiable(_selectedPath);

  /// Meryem: ekrandaki hedef toplam.
  int get targetSum => _targetSum;

  int get score => _score;

  /// Esma: son başarılı hamlede kazanılan puan (Snackbar)
  int get lastSubmittedMoveGain => _lastSubmittedMoveGain;
  bool get isResolvingExplosion => _explosionCells.isNotEmpty;
  int get explosionAnimGen => _explosionAnimGen;
  bool get isShowingError => _isShowingError;

  bool isCellExploding(int row, int col) =>
      _explosionCells.any((p) => p.row == row && p.col == col);

  /// Esma: seçim vurgusu için
  bool isCellSelected(int row, int col) =>
      _selectedPath.any((p) => p.row == row && p.col == col);

  GameEngine() {
    _initGrid();
    _rollNewTarget();
    _startTimers();
    _spawnNewRow();
  }

  /// Meryem · Üye 3 (Vize Madde 4): hedef sayı üretimi.
  ///
  /// Öncelik: mevcut gridde üretilebilen komşu zincir toplamlarından rastgele seçmek.
  /// Fallback: minTargetSum-maxTargetSum aralığından rastgele sayı.
  void _rollNewTarget() {
    _targetSum = TargetNumberEngine.generateTarget(
      grid: _grid,
      rnd: _rnd,
      minSelectionCount: minSelectionCount,
      maxSelectionCount: maxSelectionCount,
      minTargetSum: minTargetSum,
      maxTargetSum: maxTargetSum,
    );
  }

  /// Esma  & Sude : hamle onayı — doğruysa patlama animasyonu, yanlışsa yanlış seçim
  SubmitMoveResult submitMove() {
    _lastSubmittedMoveGain = 0;
    if (validateMoveSelection() != MoveSelectionValidation.ok) {
      return SubmitMoveResult.invalidSelection;
    }

    if (selectedValuesSum != _targetSum) {
      /// Sude · Üye 4 — Madde 8: Hata bayrağını kaldır, 1 saniye sonra temizle.
      _isShowingError = true;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 1000), () {
        _isShowingError = false;
        _selectedPath.clear();
        notifyListeners();
      });
      return SubmitMoveResult.wrongSum;
    }

    /// Sude : Doğru işlem durumunda patlama animasyonunu tetikle.
    _explosionAnimGen++;
    _explosionCells.clear();
    _explosionCells.addAll(List<GridPos>.from(_selectedPath));
    _selectedPath.clear();
    notifyListeners();
    return SubmitMoveResult.explosionStarted;
  }

  void completeExplosionAfterAnimation() {
    if (_explosionCells.isEmpty) return;

    var gained = 0;
    for (final p in _explosionCells) {
      final b = _grid[p.row][p.col];
      if (b != null) gained += DigitScores.pointsFor(b.value);
    }
    _score += gained;

    for (final p in _explosionCells) {
      _grid[p.row][p.col] = null;
    }
    _explosionCells.clear();
    _applyGravityAndRefill();
    _rollNewTarget();
    _lastSubmittedMoveGain = gained;
    notifyListeners();
  }


  /// Esma: doğru hamle sonrası (PDF) — sütunlarda aşağı kayma + üstten 1–9 doldurma
  /// Sude : boşalan yerler rastgele doldurulmaz, sadece mevcut bloklar aşağı kayar.
  void _applyGravityAndRefill() {
    for (var c = 0; c < cols; c++) {
      // Sütundaki mevcut (boş olmayan) blokları topla
      final preserved = <int>[];
      for (var r = rows - 1; r >= 0; r--) {
        final b = _grid[r][c];
        if (b != null) preserved.add(b.value);
      }

      // Sütunu tamamen boşalt
      for (var r = 0; r < rows; r++) {
        _grid[r][c] = null;
      }

      // Toplanan blokları en alttan başlayarak yukarı doğru yerleştir
      var write = rows - 1;
      for (final v in preserved) {
        _grid[write][c] = Block(value: v, row: write, col: c);
        write--;
      }

      // Üstte kalan 'write' indeksli satırlar null (boş) kalır.
      // Yeni bloklar sadece _spawnNewRow zamanlayıcısı ile üstten düşer.
    }
    notifyListeners();
  }

  /// Elif: başlangıç — alt 3 satır dolu
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

  ///Elif: düşen blokları kaydır, tabana yerleştir
  void _onFallTick() {
    /// Sude : Patlama anında düşmeyi durdurarak görsel titremeyi önle.
    if (isResolvingExplosion) return;

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

  /// Elif: düşen bloğu gride yaz
  void _settleBlock(FallingBlock fb) {
    final r = fb.row.toInt().clamp(0, rows - 1);
    if (r < rows && _grid[r][fb.col] == null) {
      _grid[r][fb.col] = Block(value: fb.value, row: r, col: fb.col);
    }
  }

  /// Elif: periyodik olarak üstten yeni blok
  void _spawnNewRow() {
    /// Sude :Patlama anında yeni blok üretimini engelle.
    if (isResolvingExplosion) return;

    final fallingCols = _fallingBlocks.map((fb) => fb.col).toSet();
    for (int c = 0; c < cols; c++) {
      if (_grid[0][c] == null && !fallingCols.contains(c)) {
        _fallingBlocks
            .add(FallingBlock(col: c, row: -1, value: _rnd.nextInt(9) + 1));
      }
    }
    notifyListeners();
  }

  /// Esma · Madde 5–6: dokunmatik seçim + komşu zincir ([AdjacencyRules])
  SelectionTapResult onCellTapped(int row, int col) {
    /// Sude : Animasyon veya hata varken girişi engelle.
    if (isResolvingExplosion || _isShowingError)
      return SelectionTapResult.rejectedEmpty;

    if (row < 0 || row >= rows || col < 0 || col >= cols)
      return SelectionTapResult.rejectedEmpty;
    if (_grid[row][col] == null) return SelectionTapResult.rejectedEmpty;

    final pos = GridPos(row, col);
    final existingIndex = _selectedPath.indexWhere((p) => p == pos);

    if (existingIndex >= 0) {
      final isLast = existingIndex == _selectedPath.length - 1;
      if (isLast) {
        _selectedPath.removeLast();
        notifyListeners();
        return _selectedPath.isEmpty
            ? SelectionTapResult.cleared
            : SelectionTapResult.shortened;
      }
      _selectedPath.removeRange(existingIndex + 1, _selectedPath.length);
      notifyListeners();
      return SelectionTapResult.shortened;
    }

    if (_selectedPath.isEmpty) {
      _selectedPath.add(pos);
      notifyListeners();
      return SelectionTapResult.extended;
    }

    if (_selectedPath.length >= maxSelectionCount)
      return SelectionTapResult.rejectedMaxLength;

    final last = _selectedPath.last;
    if (!AdjacencyRules.areNeighbors(last.row, last.col, row, col)) {
      return SelectionTapResult.rejectedNotAdjacent;
    }

    _selectedPath.add(pos);
    notifyListeners();
    return SelectionTapResult.extended;
  }

  MoveSelectionValidation validateMoveSelection() {
    if (_selectedPath.length < minSelectionCount)
      return MoveSelectionValidation.tooFewBlocks;
    if (_selectedPath.length > maxSelectionCount)
      return MoveSelectionValidation.tooManyBlocks;
    if (!AdjacencyRules.isValidNeighborChain(_selectedPath))
      return MoveSelectionValidation.invalidNeighborChain;
    return MoveSelectionValidation.ok;
  }

  int get selectedValuesSum {
    var s = 0;
    for (final p in _selectedPath) {
      final b = _grid[p.row][p.col];
      if (b != null) s += b.value;
    }
    return s;
  }

  void clearSelection() {
    _selectedPath.clear();
    _isShowingError = false;
    notifyListeners();
  }

  /// Elif + Esma: oyunu sıfırla (grid, düşen bloklar, seçim, hedef, puan)
  void restartGame() {
    _fallTimer?.cancel();
    _spawnTimer?.cancel();
    _fallingBlocks.clear();
    _selectedPath.clear();
    _explosionCells.clear();
    _isShowingError = false;
    _score = 0;
    _lastSubmittedMoveGain = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) _grid[r][c] = null;
    }
    _initGrid();
    _rollNewTarget();
    _startTimers();
    _spawnNewRow();
    notifyListeners();
  }

  @override
  void dispose() {
    _fallTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }
}
