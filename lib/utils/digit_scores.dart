/// [Esma] tarafından hazırlanan puanlama tablosu (PDF Madde 5).
/// Her blok değerinin patladığında kazandıracağı puanları belirler.
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
