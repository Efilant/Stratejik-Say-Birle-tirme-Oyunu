# 3. görev kişisi meryem — Rapor Katkısı

Bu doküman, final aşaması için eklenen iki ana katkının rapora doğrudan eklenebilmesi amacıyla hazırlanmıştır.

## 3. görev kişisi meryem — Süre Azalma Mekanizması (Madde 3)

Oyunun dinamiğini artırmak için blok üretim zamanlayıcısı toplam puana bağlı olarak kademeli şekilde hızlandırılır. Başlangıç süresi 5 saniyedir ve oyuncu puan kazandıkça üretim aralığı düşer. Minimum süre 1 saniye ile sınırlandırılmıştır.

### Hızlanma Eğrisi

- 1-99 puan: 5 saniye
- 100-199 puan: 4 saniye
- 200-299 puan: 3 saniye
- 300-399 puan: 2 saniye
- 400 ve üzeri: 1 saniye

### Teknik Uygulama Özeti

- Puan tabanlı eşik hesabı `GameEngine.spawnIntervalForScore()` fonksiyonu ile yapılır.
- Toplam puan her doğru hamleden sonra güncellendiğinde eşik tekrar hesaplanır.
- Eşik değiştiyse mevcut spawn timer iptal edilip yeni süreyle tekrar başlatılır.
- Böylece oyun, oturum boyunca otomatik olarak zorlaşır ve manuel müdahale gerektirmez.

## 3. görev kişisi meryem — Liderlik Tablosu (Madde 5)

Skorların cihaz içinde kalıcı tutulması için `shared_preferences` kullanılır. Her oyun bitiminde skor verisi yerel belleğe kaydedilir ve oyun sonu ekranında sıralı şekilde gösterilir.

### Veri Saklama Yöntemi

- Depolama anahtarı: `leaderboard_scores`
- Veri formatı: JSON dizi (`score`, `playedAt`)
- Saklama limiti: en fazla 100 kayıt
- Okuma sırasında skorlar yüksekten düşüğe sıralanır

### Kullanıcıya Sunum

- Oyun sonu ekranında en iyi skorlar listelenir.
- Güncel oyun skoru listede görsel olarak vurgulanır.
- Skorlar yerel tutulduğu için internet bağlantısı gerektirmez.

## Test ve Doğrulama Notu

- Süre azalma eğrisi birim test ile doğrulanmıştır: `test/spawn_interval_curve_test.dart`
