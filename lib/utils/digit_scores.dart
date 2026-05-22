/// [Esma] tarafından hazırlanan puanlama tablosu (PDF Bölüm 5 / Final Madde 2).
/// Her sayı (1–9) için sabit puan değeri; hamle puanı bu değerlerin toplamıdır.
class DigitScores {
  DigitScores._();

  static const Map<int, int> byValue = {
    1: 1,
    2: 2,
    3: 3,
    4: 5,
    5: 7,
    6: 9,
    7: 12,
    8: 15,
    9: 20,
  };

  static int pointsFor(int value) => byValue[value] ?? 0;
}
