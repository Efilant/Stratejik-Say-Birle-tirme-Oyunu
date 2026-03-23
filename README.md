# Stratejik Sayı Birleştirme

Kocaeli Üniversitesi Yazılım Geliştirme 2 projesi. 8×10 matris üzerinde komşu blokları seçerek hedef sayıya ulaşma oyunu.

**author:** Elif

---

## Proje Yapısı

```
lib/
├── models/          # Block, Score modelleri
├── providers/       # GameEngine (oyun mantığı)
├── screens/         # GameScreen
├── widgets/         # GameGrid, BlockWidget, ScoreBoard, TargetDisplay
└── utils/           # Renk sabitleri, yardımcı fonksiyonlar
```

---

## Yapılanlar (Vize - Üye 1)

### Flutter Teknik Mimarisi
- Provider ile state management
- modüler klasör yapısı

### Modeller
- **Block**: sayı (1–9), satır, sütun, renk
- **ScoreEntry**: liderlik tablosu için (Final’da kullanılacak)
- **color_constants**: 1=Mavi, 2=Yeşil, 3=Sarı, vb. sabit palet

### GameEngine (Grid & Mekanik)
- **8×10 matris**: `List<List<Block?>>`
- **Başlangıç**: ilk 3 satır rastgele bloklarla dolu
- **Blok düşme**: Timer (500ms) ile birim birim aşağı kayma
- **Tabana yerleşme**: alt hücre dolu veya satır 9’da ise blok yerleşir
- **Spawn**: her 5 saniyede her sütuna üstten yeni blok

### UI
- **BlockWidget**: sayıya göre renklendirilmiş blok
- **GameGrid**: GridView + Stack (yerleşik + düşen bloklar)
- **GameScreen**: hedef sayı, puan, oyun alanı

---

## Çalıştırma

```bash
flutter pub get
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run              # Varsayılan cihaz
```

---

## Sonraki Adımlar (Ekip)

| Üye   | Vize                         | Final                      |
|-------|------------------------------|----------------------------|
| Üye 2 | Blok seçimi, komşuluk        | Patlama, puan motoru       |
| Üye 3 | Hedef sayı, yanlış sayacı    | Hızlanma, SharedPreferences|
| Üye 4 | Material UI, renk paleti     | Liderlik tablosu, animasyon|
