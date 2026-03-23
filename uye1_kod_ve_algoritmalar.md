# Üye 1 – Kod ve Algoritmalar Dokümantasyonu

**author:** Elif  
**Görev:** Grid & Mekanik Mimarı (Core Developer)  
**Vize Kapsamı:** 8×10 matris, Timer ile blok düşme, tabana yerleşme

---

## 1. Dosya Konumları ve İşlevleri

| Dosya | Konum | İşlev |
|-------|-------|-------|
| **Block modeli** | `lib/models/block.dart` | Yerleşmiş blok verisi: sayı, satır, sütun, renk |
| **FallingBlock + GameEngine** | `lib/providers/game_engine.dart` | Matris, düşme ve yerleşme mantığı |
| **Renk sabitleri** | `lib/utils/color_constants.dart` | Sayı–renk eşleştirmesi (1=Mavi, 2=Yeşil, vb.) |
| **GameGrid** | `lib/widgets/game_grid.dart` | 8×10 grid ve düşen blokların çizimi |
| **BlockWidget** | `lib/widgets/block_widget.dart` | Tek blok görünümü (sayı + renk) |
| **GameScreen** | `lib/screens/game_screen.dart` | Ana oyun ekranı layout'u |

---

## 2. Metodlar ve Ne İşe Yaradıkları

### 2.1 `lib/models/block.dart`

| Metod/Özellik | Açıklama |
|---------------|----------|
| `Block(value, row, col)` | Yerleşmiş bloğun sayı ve konum bilgisi |
| `color` getter | `blockColors` üzerinden sayıya göre renk |
| `copyWith()` | Blok kopyalama / alan güncelleme (ileride kullanım için) |

---

### 2.2 `lib/providers/game_engine.dart`

| Metod | Satır | İşlev |
|-------|-------|-------|
| **`_initGrid()`** | 39–45 | Oyun başlangıcında alt 3 satırı (7,8,9) rastgele bloklarla doldurur. Üst satırlar boş kalır, böylece bloklar düşebilir. |
| **`_startTimers()`** | 46–49 | `_fallTimer` (500ms) ve `_spawnTimer` (5sn) başlatır. |
| **`_onFallTick()`** | 52–73 | Her 500ms tetiklenir. Düşen blokları bir satır aşağı kaydırır, yerleşmesi gerekenleri `_settleBlock` ile gride alır. |
| **`_settleBlock()`** | 76–81 | Blok tabana veya altındaki bloğa değdiğinde matrise yerleştirir. |
| **`_spawnNewRow()`** | 84–96 | Her 5 sn üst satır boş ve o sütunda düşen blok yoksa yeni blok ekler. |
| **`dispose()`** | 98–102 | Timer’ları iptal eder, kaynak temizliği yapar. |

---

### 2.3 `lib/widgets/game_grid.dart`

| Bileşen | İşlev |
|---------|-------|
| **GridView.builder** | 8×10 matrisi hücre hücre çizer; `grid[row][col]` değerlerine göre yerleşmiş blokları gösterir. |
| **Stack + Positioned** | Düşen blokları (`fallingBlocks`) `row`, `col` bilgisiyle üstte overlay olarak çizer. |

---

## 3. Algoritma Mantığı

### 3.1 Veri Yapısı

```
_grid: List<List<Block?>>
  - 10 satır (row 0 = üst, row 9 = alt)
  - 8 sütun (col 0–7)
  - null = boş hücre

_fallingBlocks: List<FallingBlock>
  - col: sütun
  - row: anlık satır (double, animasyon için)
  - value: 1–9 arası sayı
```

### 3.2 Blok Düşme (State Machine)

```
[SPAWN] row=-1 (grid üstü)
    ↓
[FALL]  row++ (her 500ms)
    ↓
[CHECK] nextRow < 10 VE _grid[nextRow][col] == null ?
    ├─ EVET → FALL’a dön
    └─ HAYIR → SETTLE
         ↓
[SETTLE] _grid[row][col] = Block
         _fallingBlocks’tan çıkar
```

### 3.3 Tabana Yerleşme Kontrolü

```text
canFall = (nextRow < 10) VE (_grid[nextRow][col] == null)

Yerleşme koşulları:
  - nextRow >= 10  →  En alta geldi
  - _grid[nextRow][col] != null  →  Altında blok var
```

### 3.4 Spawn Koşulları

```text
Yeni blok eklenir ancak:
  - _grid[0][col] == null  (üst hücre boş)
  - O sütunda zaten düşen blok yok
```

---

## 4. Sözde Kod (Pseudo-code)

### 4.1 Ana Döngü (_onFallTick)

```
her 500ms:
  toSettle = []
  for her fb in _fallingBlocks:
    nextRow = fb.row + 1
    if nextRow < 10 VE grid[nextRow][fb.col] boş:
      fb.row = nextRow
    else:
      toSettle.ekle(fb)
  
  for her fb in toSettle:
    grid[fb.row][fb.col] = yeni Block(fb.value, fb.row, fb.col)
    _fallingBlocks.sil(fb)
  
  notifyListeners()
```

### 4.2 Spawn

```
her 5 saniye:
  fallingCols = {düşen blokların sütunları}
  for c = 0 to 7:
    if grid[0][c] boş VE c ∉ fallingCols:
      _fallingBlocks.ekle(FallingBlock(col:c, row:-1, value:random(1..9)))
```

---

## 5. Timer Kullanımı

| Timer | Süre | Görev |
|-------|------|-------|
| `_fallTimer` | 500 ms | Blokların birim birim aşağı inmesi |
| `_spawnTimer` | 5 sn | Üstten yeni blok satırı eklenmesi |

`Timer.periodic` kullanılır; Ticker yerine tercih edilmiştir çünkü ayrık zaman adımları (500ms) yeterlidir.

---

## 6. Görsel Akış Özeti

```
Başlangıç:
  ┌─────────────────┐
  │  boş (0–6)      │  ← Yeni bloklar buradan düşer
  ├─────────────────┤
  │  dolu (7,8,9)   │  ← İlk 3 satır
  └─────────────────┘

Düşme:
  Blok row=-1’den başlar → 0,1,2... → En altta veya bloğun üstünde durur
```
