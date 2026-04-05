# Stratejik Sayı Birleştirme - Geliştirme Notları

Bu depo, Flutter ile yazılmış bulmaca oyununun kaynak kodunu içerir. Aşağıda son yapılan değişiklikler, çalıştırma talimatları ve iOS yükleme notları yer almaktadır.

## Son Değişiklikler (branch: `responsive-grid-fixes`)

- UI: Seçim görselliği geliştirmeleri
  - Seçilen bloklarda belirgin dış beyaz çerçeve (ring effect) ve parlama (glow) eklendi.
  - Seçim sırasını gösteren küçük badge (index) eklendi.
  - `AnimatedScale` kullanılarak seçilen bloklara hafif büyüme (tactile feedback) verildi.

- Grid ve yerleşim (responsive)
  - `GameGrid` responsive hale getirildi; hücre boyutu `LayoutBuilder` ile hesaplanıyor.
  - Spacing/padding azaltıldı, hafif bir shrink factor uygulandı; böylece 8×10 grid küçük ekranlara daha iyi sığıyor.

- Görsel-mekanik entegrasyonu
  - Doğru hamlede patlama animasyonu: başarılı hamlelerde ilgili bloklar büyüyor (scale 1.25) ve beyaz-neon tarzı parlama ile sahadan kaldırılıyor.
  - Patlama animasyonları sırasında düşme zamanlayıcıları geçici olarak durduruluyor; animasyon bitince düşmeler tekrar başlatılıyor.

Değiştirilen ana dosyalar:

- `lib/widgets/block_widget.dart` — seçim görselleştirmeleri, badge ve patlama animasyonu.
- `lib/widgets/game_grid.dart` — responsive grid hesaplamaları, `Stack`/`Positioned` ile stabil yerleşim.
- `lib/providers/game_engine.dart` — patlama ve fall-tick senkronizasyonu.

## Hızlı Çalıştırma (geliştirici/debug)

1. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

2. Uygulamayı iOS simülatörde çalıştırın:

```bash
flutter run -d <simulator-id>
```

3. Fiziksel iPhone'a debug (development) olarak yüklemek için cihazı bağlayın veya kablosuz olarak görünmesini sağlayın, ardından:

```bash
flutter run -d <device-id>
```

Not: Debug yükleme için Apple Developer hesabı veya dağıtım sertifikası gerekmez; ancak cihazınızda "Trust this computer" onayı ve gerekli geliştirici izinlerinin açık olması gerekir.

## Release / IPA Oluşturma Notları

- `flutter build ipa` çalıştırıldığında Xcode ile arşivlenir ve export sırasında Apple Developer hesabı, dağıtım profilleri (provisioning profile) ve dağıtım sertifikası gereklidir.
- Mevcut proje hâlâ `com.example` bundle identifier içeriyor; App Store/TestFlight dağıtımı için `bundle identifier` ve App Icon/Launch Image gibi meta verilerin değiştirilmesi gerekir.

Özet: debug kurulum için `flutter run` en hızlı yoldur. Kalıcı dağıtım (TestFlight/App Store/Ad-Hoc) için Apple geliştirici erişimi ve uygun provisioning adımları gereklidir.

## Branch ve Commit Durumu

- Son UI ve grid düzeltmeleri `responsive-grid-fixes` branch'inde yapılmış ve daha önce uzak repoya push edilmiştir.
- Bu README güncellemesi de aynı branch üzerinde commit edilip push edilecektir.

---

Eğer bu README'yi projenin `docs/` dizinine veya proje açıklamasına (README Türkçe/İngilizce split) taşımamı isterseniz söyleyin; ayrıca çalıştırma/cihaz yükleme adımlarını daha ayrıntılı bir "How to test" bölümüne taşıyabilirim.
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
