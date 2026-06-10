# Stratejik Sayı Birleştirme Oyunu

Bu proje, Kocaeli Üniversitesi Yazılım Mühendisliği bölümü **Yazılım Geliştirme 2** dersi kapsamında geliştirilen, strateji ve matematik temelli bir mobil bulmaca oyunudur.

**Depo:** [github.com/Efilant/Stratejik-Say-Birle-tirme-Oyunu](https://github.com/Efilant/Stratejik-Say-Birle-tirme-Oyunu)

## Oyunun Amacı

8×10 boyutundaki bir matris üzerinde, komşu olan (yatay, dikey, çapraz) sayı bloklarını birbirine bağlayarak ekranın üstünde gösterilen **Hedef Sayı**'ya ulaşmak ve puan toplamaktır. Üst satır dolduğunda oyun biter; skorun isimli liderlik tablosuna kaydedilir.

---

## Proje Ekibi ve Rol Dağılımı

| Üye | Rol | Sorumluluklar |
| :--- | :--- | :--- |
| **Elif** | Geliştirici | Izgara yapısı (8×10), hücre temelli düşme mekaniği ve fizik motoru |
| **Esma** | Geliştirici | Seçim algoritmaları, komşuluk kuralları (8 yön), patlama mantığı ve puan hesaplama |
| **Meryem** | Geliştirici | Hedef sayı üretim motoru (DFS), süre azalma mekanizması, giriş sayfası ve liderlik tablosu |
| **Sude** | Geliştirici | Modern UI tasarımı, hata yönetimi, oyun sonu ekranı, stabilite ve görsel efektler |

---

## Oyun Akışı

1. **Giriş sayfası** — Oyuncu adı girilir; mevcut skor tablosu önizlenir.
2. **Oyun ekranı** — Hedef sayıya uygun bloklar seçilir, onaylanır ve patlatılır.
3. **Oyun sonu** — Final puanı kaydedilir, en iyi 5 skor listelenir; tekrar oyna veya ana sayfaya dön.

---

## Temel Mekanikler

### 1. Izgara ve Bloklar
- Oyun **8 sütun × 10 satır** dinamik matris üzerinde oynanır.
- Bloklar **1–9** arası rastgele tam sayı değerleri alır.
- Başlangıçta ızgara, rastgele **3 satır dolu** olarak başlar.

### 2. Akıllı Düşme Sistemi
- Yeni bloklar üstten **birim birim** hareket ederek düşer.
- Blok üretim süresi başlangıçta **5 saniyedir**; toplam puana göre **1 saniyeye kadar** kademeli hızlanır.
- Bir blok patladığında üstteki bloklar yerçekimi kurallarına uygun olarak alt boşlukları doldurur.

### 3. Seçim ve Komşuluk Kuralları
- En az **2**, en fazla **4** blok birleştirilebilir.
- Birleştirilen bloklar birbirine **yatay, dikey veya çapraz** komşu olmalıdır.
- Seçilen bloklar görsel olarak bağlanır ve seçim sırası numaralandırılır.

### 4. Hedef Sayı Motoru
- Hedef sayı, grid üzerinde o an elde edilebilecek gerçek senaryolara göre üretilir (DFS tabanlı tarama).
- Oyunun tıkanması engellenir; her hamle sonrası yeni hedef belirlenir.

### 5. Hata ve Ceza Mekanizması
- Yanlış toplam yapıldığında hata sayacı artar (`Hata: x/3`).
- **3. hatalı denemede** ceza olarak tüm sütunlardan aynı anda yeni bloklar indirilir.
- Ceza sonrası hata sayacı sıfırlanır.

### 6. Puan Sistemi (Final)
Doğru hamlede patlayan blokların **sabit puan tablosu** toplanır (sayısal toplam değil):

| Rakam | Puan |
| :---: | :---: |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 5 |
| 5 | 7 |
| 6 | 9 |
| 7 | 12 |
| 8 | 15 |
| 9 | 20 |

### 7. Oyun Sonu (Final)
- **Otomatik:** Üst satır (0. satır) herhangi bir hücre dolunca oyun biter.
- **Manuel:** Oyuncu "Oyunu Bitir" ile skorunu kaydedip çıkabilir.
- Oyun sonu ekranında final puanı, seviye etiketi ve en iyi 5 skor gösterilir.

### 8. Liderlik Tablosu (Final)
- `shared_preferences` ile cihazda kalıcı saklama.
- Her kayıt: **oyuncu adı**, **puan**, **tarih**.
- Skorlar yüksekten düşüğe sıralanır; en fazla **100 kayıt** tutulur.
- Giriş sayfası ve oyun sonu ekranında listelenir.

---

## Süre Azalma Mekanizması (Final)

Toplam puana göre blok üretim aralığı otomatik kısalır:

| Toplam Puan | Üretim Aralığı |
| :--- | :---: |
| 0 – 99 | 5 sn |
| 100 – 199 | 4 sn |
| 200 – 299 | 3 sn |
| 300 – 399 | 2 sn |
| 400+ | 1 sn |

Eşik değiştiğinde spawn timer yeni süreyle otomatik yeniden başlatılır.

---

## Teknik Mimari

| Bileşen | Teknoloji |
| :--- | :--- |
| Framework | Flutter |
| State Management | Provider (`ChangeNotifier`) |
| Yerel depolama | `shared_preferences` |
| Tasarım | Material 3, neon & glassmorphism |
| Veri yapısı | 2D matris (`List<List<Block?>>`) + özel sınıflar |

### Proje Yapısı

```
lib/
├── main.dart                 # Uygulama girişi, tema
├── providers/
│   └── game_engine.dart      # Oyun motoru (grid, timer, ceza, oyun sonu)
├── logic/
│   ├── adjacency_rules.dart  # 8 yönlü komşuluk kuralları
│   ├── move_score_calculator.dart
│   └── target_number_engine.dart
├── services/
│   └── score_repository.dart # Liderlik tablosu (JSON + SharedPreferences)
├── screens/
│   ├── welcome_screen.dart   # Giriş sayfası
│   └── game_screen.dart      # Ana oyun ekranı
├── widgets/                  # Grid, skor tablosu, oyun sonu, efektler
├── models/                   # Block, GridPos
└── utils/                    # Renkler, puan tablosu
```

---

## Kurulum ve Çalıştırma

Flutter SDK yüklü olmalıdır.

```bash
git clone https://github.com/Efilant/Stratejik-Say-Birle-tirme-Oyunu.git
cd Stratejik-Say-Birle-tirme-Oyunu
flutter pub get
flutter run
```

Belirli bir platform için:

```bash
flutter run -d macos    # macOS
flutter run -d chrome   # Web
flutter run -d ios      # iOS (cihaz/emülatör gerekir)
```

Testler:

```bash
flutter test
```

---

## Vize Aşaması Özeti

Vize gereksinimleri — hücre temelli hareket, ceza mekanizması, akıllı hedef üretimi ve komşuluk kuralları — tamamlanmıştır. Kod dokümantasyonu Türkçe olarak standardize edilmiştir.

---

## Final Aşaması Özeti

| Özellik | Durum | İlgili Dosyalar |
| :--- | :---: | :--- |
| Puan hesaplama sistemi | ✅ | `lib/logic/move_score_calculator.dart`, `lib/utils/digit_scores.dart` |
| Süre azalma mekanizması | ✅ | `lib/providers/game_engine.dart` |
| Oyun sonu ekranı | ✅ | `lib/widgets/game_over_screen.dart` |
| İsimli liderlik tablosu | ✅ | `lib/services/score_repository.dart`, `lib/screens/welcome_screen.dart` |
| Giriş sayfası | ✅ | `lib/screens/welcome_screen.dart` |
| Patlama animasyonları | ✅ | `lib/widgets/exploding_block_widget.dart` |


**Test dosyaları:**
- `test/move_score_calculator_test.dart`
- `test/spawn_interval_curve_test.dart`

---

## Lisans

Kocaeli Üniversitesi Yazılım Geliştirme 2 ders projesi kapsamında geliştirilmiştir.
