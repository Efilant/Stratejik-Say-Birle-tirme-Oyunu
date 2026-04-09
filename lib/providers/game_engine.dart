import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../logic/adjacency_rules.dart';
import '../logic/target_number_engine.dart';
import '../models/block.dart';
import '../models/grid_pos.dart';
import '../utils/digit_scores.dart';

// ===========================================================================
// PROJE EKİBİ VE GÖREV DAĞILIMI
// ---------------------------------------------------------------------------
// Üye 1 — Elif: Grid yapısı (8x10), blok düşme mekaniği ve spawn sistemi.
// Üye 2 — Esma: Seçim algoritmaları, hamle doğrulama ve patlama mantığı.
// Üye 3 — Meryem: Hedef sayı üretim motoru (Vize Madde 4).
// Üye 4 — Sude: Görsel stabilite, hata yönetimi ve kesintisiz akış kontrolü.
// ===========================================================================

/// [Esma] tarafından hazırlanan dokunma geri bildirim sonuçları.
/// Kullanıcı arayüzünde (SnackBar vb.) doğru mesajın gösterilmesini sağlar.
enum SelectionTapResult {
  extended,            // Zincire yeni bir komşu eklendi
  shortened,           // Zincir son adımdan geri alındı
  cleared,             // Seçim tamamen temizlendi
  rejectedEmpty,       // Boş hücreye dokunuldu
  rejectedNotAdjacent, // Seçilen hücre son elemana komşu değil (PDF Madde 4)
  rejectedMaxLength,   // Maksimum blok sınırına (4) ulaşıldı
}

/// [Esma] tarafından kurgulanan hamle doğrulama durumları.
/// Seçim zincirinin kurallara (2-4 blok ve komşuluk) uygunluğunu denetler.
enum MoveSelectionValidation {
  ok,
  tooFewBlocks,
  tooManyBlocks,
  invalidNeighborChain
}

/// [Esma] tarafından yönetilen hamle sonuçları.
/// Hedef kontrolü ve patlama animasyonu tetikleyicisi.
enum SubmitMoveResult {
  invalidSelection, // Seçim kriterlere uymuyor
  wrongSum,         // Toplam hedef sayıdan farklı
  explosionStarted, // Doğru hamle; patlama süreci başladı
}

/// [Elif] ve [Sude] iş birliğiyle hazırlanan düşen blok modeli.
/// Milimetrik kaymaları ve görsel hataları önlemek için benzersiz bir [id] taşır.
class FallingBlock {
  static int _idCounter = 0;
  final int col;
  double row;
  final int value;
  final String id;

  FallingBlock({required this.col, required this.row, required this.value})
      : id = 'fb_${_idCounter++}_${DateTime.now().microsecondsSinceEpoch}';
}

/// Oyun motoru: Üye 1 (Elif) grid & düşme + Üye 2 (Esma) seçim & hedef hamlesi.
/// [Elif] (Fizik/Grid), [Esma] (Seçim/Kural), [Meryem] (Hedef) ve [Sude] (Stabilite)
/// katkılarıyla geliştirilmiştir.
class GameEngine extends ChangeNotifier {
  // --- Sabitler (Oyun Kuralları) ---
  static const int rows = 10;
  static const int cols = 8;
  static const int initialFilledRows = 3;
  static const int minSelectionCount = 2;
  static const int maxSelectionCount = 4;
  static const int minTargetSum = 2;
  static const int maxTargetSum = 36;
  
  static const Duration fallInterval = Duration(milliseconds: 500); // Düşme hızı
  static const Duration spawnInterval = Duration(seconds: 5); // Yeni blok oluşma sıklığı
  static const Duration explosionEffectDuration = Duration(milliseconds: 420); // Patlama efekti süresi

  // --- İç Durum (Private State) ---
  final List<List<Block?>> _grid = List.generate(rows, (_) => List.filled(cols, null));
  final List<FallingBlock> _fallingBlocks = [];
  final List<GridPos> _selectedPath = [];
  final List<GridPos> _explosionCells = [];
  final Random _rnd = Random();
  
  Timer? _fallTimer;
  Timer? _spawnTimer;
  
  int _targetSum = 9;
  int _score = 0;
  int _lastSubmittedMoveGain = 0;
  int _explosionAnimGen = 0;
  bool _isShowingError = false;
  int _wrongMoveCount = 0;

  // --- Getters (Arayüz Erişimi) ---
  List<List<Block?>> get grid => _grid;
  List<FallingBlock> get fallingBlocks => List.unmodifiable(_fallingBlocks);
  List<GridPos> get selectedPath => List.unmodifiable(_selectedPath);
  int get targetSum => _targetSum;
  int get score => _score;
  int get lastSubmittedMoveGain => _lastSubmittedMoveGain;
  bool get isResolvingExplosion => _explosionCells.isNotEmpty;
  int get explosionAnimGen => _explosionAnimGen;
  bool get isShowingError => _isShowingError;
  int get wrongMoveCount => _wrongMoveCount;

  // --- Yapıcı Metot ve Yaşam Döngüsü ---
  GameEngine() {
    _initGrid();
    _rollNewTarget();
    _startTimers();
    _spawnNewBlocks();
  }

  @override
  void dispose() {
    _fallTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  // --- Başlatma Ve Temel Ayarlar ---

  /// [Elif] tarafından hazırlanan başlangıç grid yapısı.
  /// Oyunun başında en alt 3 satırı rastgele rakamlarla doldurur.
  void _initGrid() {
    for (int r = rows - initialFilledRows; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _grid[r][c] = Block(value: _rnd.nextInt(9) + 1, row: r, col: c);
      }
    }
  }

  void _startTimers() {
    _fallTimer = Timer.periodic(fallInterval, (_) => _onFallTick());
    _spawnTimer = Timer.periodic(spawnInterval, (_) => _spawnNewBlocks());
  }

  /// [Meryem] tarafından geliştirilen hedef sayı üretim sistemi.
  /// Madde 4: Griddeki mevcut ihtimalleri (2-4 blokluk komşu zincirler) gözeterek adil bir hedef belirler.
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

  // --- Oyun Kontrolleri Ve Hamle Yönetimi ---

  /// [Esma] ve [Sude] tarafından yönetilen hamle onay süreci.
  SubmitMoveResult submitMove() {
    _lastSubmittedMoveGain = 0;
    
    // Önce seçimin temel kurallara uygunluğu denetlenir
    if (validateMoveSelection() != MoveSelectionValidation.ok) {
      return SubmitMoveResult.invalidSelection;
    }

    // Seçilen blokların toplamı hedefe eşit mi?
    if (selectedValuesSum != _targetSum) {
      _wrongMoveCount++;
      _isShowingError = true;
      notifyListeners();

      // Hata durumunda 1 saniye görsel uyarı ver ve seçimi temizle [Sude]
      Future.delayed(const Duration(milliseconds: 1000), () {
        _isShowingError = false;
        _selectedPath.clear();
        
        // 3. hatada ceza mekanizmasını tetikle (PDF Madde 4)
        if (_wrongMoveCount >= 3) {
          _applyPenaltyDescending();
        }
        
        notifyListeners();
      });
      return SubmitMoveResult.wrongSum;
    }

    // Başarılı hamle: Patlama animasyonunu tetikle [Sude]
    _explosionAnimGen++;
    _explosionCells.clear();
    _explosionCells.addAll(List<GridPos>.from(_selectedPath));
    _selectedPath.clear();
    notifyListeners();
    return SubmitMoveResult.explosionStarted;
  }

  /// Animasyon bitiminde blokların gridden silinmesi ve puanlama.
  void completeExplosionAfterAnimation() {
    if (_explosionCells.isEmpty) return;

    var gained = 0;
    for (final p in _explosionCells) {
      final b = _grid[p.row][p.col];
      if (b != null) gained += DigitScores.pointsFor(b.value);
    }
    _score += gained;

    // Patlayan hücreleri temizle ve yerçekimini uygula
    for (final p in _explosionCells) {
      _grid[p.row][p.col] = null;
    }
    _explosionCells.clear();
    _applyGravityFalling();
    _rollNewTarget();
    _lastSubmittedMoveGain = gained;
    notifyListeners();
  }

  /// [Elif] ve [Esma] tarafından hazırlanan oyun sıfırlama fonksiyonu.
  void restartGame() {
    _fallTimer?.cancel();
    _spawnTimer?.cancel();
    _fallingBlocks.clear();
    _selectedPath.clear();
    _explosionCells.clear();
    _isShowingError = false;
    _wrongMoveCount = 0;
    _score = 0;
    _lastSubmittedMoveGain = 0;
    
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) _grid[r][c] = null;
    }
    
    _initGrid();
    _rollNewTarget();
    _startTimers();
    _spawnNewBlocks();
    notifyListeners();
  }

  // --- Blok Seçim Ve Doğrulama Mantığı ---

  /// [Esma] tarafından kurgulanan hücre etkileşim sistemi.
  SelectionTapResult onCellTapped(int row, int col) {
    if (isResolvingExplosion || _isShowingError) return SelectionTapResult.rejectedEmpty;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return SelectionTapResult.rejectedEmpty;
    if (_grid[row][col] == null) return SelectionTapResult.rejectedEmpty;

    final pos = GridPos(row, col);
    final existingIndex = _selectedPath.indexWhere((p) => p == pos);

    // Eğer hücre zaten seçiliyse zinciri kısalt veya temizle
    if (existingIndex >= 0) {
      if (existingIndex == _selectedPath.length - 1) {
        _selectedPath.removeLast();
        notifyListeners();
        return _selectedPath.isEmpty ? SelectionTapResult.cleared : SelectionTapResult.shortened;
      }
      _selectedPath.removeRange(existingIndex + 1, _selectedPath.length);
      notifyListeners();
      return SelectionTapResult.shortened;
    }

    // İlk seçim yapılıyor
    if (_selectedPath.isEmpty) {
      _selectedPath.add(pos);
      notifyListeners();
      return SelectionTapResult.extended;
    }

    // Maksimum blok sınırı kontrolü
    if (_selectedPath.length >= maxSelectionCount) return SelectionTapResult.rejectedMaxLength;

    // Komşuluk kontrolü (PDF Madde 4) [AdjacencyRules] üzerinden yapılır
    final last = _selectedPath.last;
    if (!AdjacencyRules.areNeighbors(last.row, last.col, row, col)) {
      return SelectionTapResult.rejectedNotAdjacent;
    }

    _selectedPath.add(pos);
    notifyListeners();
    return SelectionTapResult.extended;
  }

  /// Mevcut seçimin kurallara (uzunluk ve zincirleme) uygunluğunu teyit eder.
  MoveSelectionValidation validateMoveSelection() {
    if (_selectedPath.length < minSelectionCount) return MoveSelectionValidation.tooFewBlocks;
    if (_selectedPath.length > maxSelectionCount) return MoveSelectionValidation.tooManyBlocks;
    if (!AdjacencyRules.isValidNeighborChain(_selectedPath)) return MoveSelectionValidation.invalidNeighborChain;
    return MoveSelectionValidation.ok;
  }

  void clearSelection() {
    _selectedPath.clear();
    _isShowingError = false;
    notifyListeners();
  }

  // --- İç Fizik Ve Mekanikler ---

  /// [Elif] ve [Esma] tarafından geliştirilen sürekli yerçekimi sistemi.
  /// Griddeki boşlukların üstündeki blokları 'FallingBlock' nesnesine dönüştürerek
  /// birim birim düşmelerini sağlar. [Sude] desteğiyle stabil hale getirilmiştir.
  void _applyGravityFalling() {
    bool changed = false;
    for (int c = 0; c < cols; c++) {
      for (int r = rows - 2; r >= 0; r--) {
        // Eğer bu hücre doluysa VE altındaki hücre boşsa
        if (_grid[r][c] != null && _grid[r + 1][c] == null) {
          final block = _grid[r][c]!;
          _grid[r][c] = null;
          _fallingBlocks.add(FallingBlock(col: c, row: r.toDouble(), value: block.value));
          changed = true;
          // Bu sütundaki üst blokların da düşmesini sağlamak için kırmıyoruz
        }
      }
    }
    if (changed) notifyListeners();
  }

  /// [Esma] ve [Sude] tarafından hazırlanan ceza mekanizması.
  /// 3 hatalı seçim sonrası bütün sütunlardan yeni bloklar indirilir (PDF Madde 4).
  void _applyPenaltyDescending() {
    for (int c = 0; c < cols; c++) {
      // Her sütun için yukarıdan düşecek yeni bir blok oluştur
      _fallingBlocks.add(FallingBlock(col: c, row: -1, value: _rnd.nextInt(9) + 1));
    }

    _wrongMoveCount = 0; // Ceza sonrası sayacı sıfırla
    notifyListeners();
  }

  /// [Elif] tarafından geliştirilen düşme döngüsü.
  /// Havada duran blokların tabana veya altındaki başka bir bloğa inmesini sağlar.
  void _onFallTick() {
    if (isResolvingExplosion) return; // Patlama sırasında görsel hata olmaması için duraklat [Sude]

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

    // Hareketi biten blokları gride kalıcı olarak yerleştir
    for (final fb in toSettle) {
      _settleBlock(fb);
      _fallingBlocks.remove(fb);
      changed = true;
    }

    // Yerçekimini tetikle (yeni boşluklar oluşmuş olabilir veya bloklar yerleşmiş olabilir)
    if (changed) {
      _applyGravityFalling();
      notifyListeners();
    }
  }

  void _settleBlock(FallingBlock fb) {
    final r = fb.row.toInt().clamp(0, rows - 1);
    if (r < rows && _grid[r][fb.col] == null) {
      _grid[r][fb.col] = Block(value: fb.value, row: r, col: fb.col);
    }
  }

  /// [Elif] ve [Sude] tarafından hazırlanan periyodik hücre üretim sistemi.
  /// Artık tüm satırı doldurmak yerine rastgele sütunlarda tekil hücreler üretir.
  void _spawnNewBlocks() {
    if (isResolvingExplosion) return;

    final fallingCols = _fallingBlocks.map((fb) => fb.col).toSet();
    final availableCols = <int>[];
    for (int c = 0; c < cols; c++) {
      if (_grid[0][c] == null && !fallingCols.contains(c)) {
        availableCols.add(c);
      }
    }

    if (availableCols.isEmpty) return;

    // Sadece 1 adet rastgele blok üret
    final c = availableCols[_rnd.nextInt(availableCols.length)];
    _fallingBlocks.add(FallingBlock(col: c, row: -1, value: _rnd.nextInt(9) + 1));
    
    notifyListeners();
  }

  // --- Yardımcı Metotlar ---

  /// Mevcut seçilen blokların değerlerinin toplamını hesaplar.
  int get selectedValuesSum {
    var total = 0;
    for (final pos in _selectedPath) {
      final b = _grid[pos.row][pos.col];
      if (b != null) total += b.value;
    }
    return total;
  }

  bool isCellExploding(int row, int col) => _explosionCells.any((p) => p.row == row && p.col == col);
  bool isCellSelected(int row, int col) => _selectedPath.any((p) => p.row == row && p.col == col);
}
