# Stratejik Sayı Birleştirme Oyunu

Bu proje, Kocaeli Üniversitesi Yazılım Mühendisliği bölümü **Yazılım Geliştirme 2** dersi kapsamında geliştirilen, strateji ve matematik temelli bir mobil bulmaca oyunudur. 

## 🎮 Oyunun Amacı
8x10 boyutundaki bir matris üzerinde, komşu olan (yatay, dikey, çapraz) sayı bloklarını birbirine bağlayarak ekranın üstünde gösterilen **Hedef Sayı**'ya ulaşmak ve puan toplamaktır.

---

## 👥 Proje Ekibi ve Rol Dağılımı

| Üye | Rol | Sorumluluklar |
| :--- | :--- | :--- |
| **Elif** | Geliştirici | Izgara Yapısı (8x10), Hücre Temelli Düşme Mekaniği ve Fizik Motoru |
| **Esma** | Geliştirici | Seçim Algoritmaları, Komşuluk Kuralları (8 Yön) ve Patlama Mantığı |
| **Meryem** | Geliştirici | Adil Hedef Sayı Üretim Motoru (DFS tabanlı) ve Puanlama Tablosu |
| **Sude** | Geliştirici | Modern UI Tasarımı, Hata Yönetimi, Stabilite ve Görsel Efektler |

---

## 🚀 Temel Mekanikler (Vize Aşaması)

### 1. Izgara ve Bloklar
- Oyun **8 sütun ve 10 satırdan** oluşan dinamik bir matris üzerinde oynanır.
- Bloklar **1-9** arası rastgele tam sayı değerleri alır.
- Başlangıçta ızgara, rastgele 3 satır dolu olarak başlar.

### 2. Akıllı Düşme Sistemi
- Yeni bloklar üstten **birim birim** hareket ederek düşer.
- Blok üretim süresi başlangıçta **5 saniyedir** ve toplam puana göre **1 saniyeye kadar** kademeli hızlanır.
- Bir blok patladığında, üstteki tüm bloklar fizik kurallarına uygun olarak gerçek zamanlı süzülerek alt boşlukları doldurur.

### 3. Seçim ve Komşuluk Kuralları
- En az 2, en fazla 4 blok birleştirilebilir.
- Birleştirilen bloklar birbirine **yatay, dikey veya çapraz** olarak komşu olmalıdır.
- Seçilen bloklar görsel olarak birbirine bağlanır ve seçim sırası numaralandırılır.

### 4. Hedef Sayı Motoru
- Hedef sayı, grid üzerinde o an mevcut olan bloklardan elde edilebilecek gerçek senaryolara göre üretilir. Bu sayede oyunun "tıkanması" engellenir.

### 5. Hata ve Ceza Mekanizması
- Yanlış toplam yapıldığında hata sayacı artar.
- **3. hatalı denemede** ceza olarak tüm sütunlardan aynı anda yeni bloklar indirilir, bu da oyun alanının hızla dolmasına neden olur.

---

## 🛠 Teknik Mimari
- **Framework:** Flutter
- **State Management:** Provider
- **Tasarım Dili:** Neon & Glassmorphism Aesthetics
- **Veri Yapısı:** Multi-dimensional List (Matrix) & Custom Classes

---

## 📦 Kurulum ve Çalıştırma

Projenin yerel ortamınızda çalıştırılması için Flutter SDK'nın yüklü olması gerekmektedir.

1. Bağımlılıkları indirin:
   ```bash
   flutter pub get
   ```

2. Uygulamayı başlatın:
   ```bash
   flutter run
   ```

---

## 📅 Vize Aşaması Özeti
Vize gereksinimleri olan "hücre temelli hareket", "ceza mekanizması", "akıllı hedef üretimi" ve "komşuluk kuralları" başarıyla tamamlanmıştır. Tüm kod dokümantasyonu Türkçe olarak standardize edilmiştir.

---

## ✅ Final Aşaması Kapanan Eksikler

### 3. görev kişisi meryem — Süre Azalma Mekanizması (Madde 3)
- Timer yönetimi puan eşiklerine göre dinamik hale getirildi.
- Hızlanma eğrisi:
  - **1-99 puan:** 5 sn
  - **100-199 puan:** 4 sn
  - **200-299 puan:** 3 sn
  - **300-399 puan:** 2 sn
  - **400+ puan:** 1 sn
- Eşik değiştiğinde spawn timer otomatik olarak yeni süre ile yeniden başlatılır.

### 3. görev kişisi meryem — Liderlik Tablosu (Madde 5)
- `shared_preferences` ile yerel skor kayıt sistemi kullanılır.
- Her oyun sonrası skor kalıcı olarak kaydedilir.
- Skorlar yüksekten düşüğe sıralanır ve oyun sonunda en iyi skorlar listelenir.

### 3. görev kişisi meryem — Rapor Katkısı
- Zorluk seviyesi (hızlanma eğrisi) ve veri saklama yaklaşımı dokümante edildi.
- Ayrıntılı rapor notu için `RAPOR_KATKISI_MERYEM.md` dosyası eklendi.
