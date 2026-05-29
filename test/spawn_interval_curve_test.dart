import 'package:flutter_test/flutter_test.dart';
import 'package:stratejik_sayi_birlestirme/providers/game_engine.dart';

void main() {
  group('3. görev kişisi meryem — süre azalma eğrisi', () {
    test('1-99 puan aralığında 5 saniye', () {
      expect(GameEngine.spawnIntervalForScore(0), const Duration(seconds: 5));
      expect(GameEngine.spawnIntervalForScore(99), const Duration(seconds: 5));
    });

    test('100-199 puan aralığında 4 saniye', () {
      expect(
          GameEngine.spawnIntervalForScore(100), const Duration(seconds: 4));
      expect(
          GameEngine.spawnIntervalForScore(199), const Duration(seconds: 4));
    });

    test('200-299 puan aralığında 3 saniye', () {
      expect(
          GameEngine.spawnIntervalForScore(200), const Duration(seconds: 3));
      expect(
          GameEngine.spawnIntervalForScore(299), const Duration(seconds: 3));
    });

    test('300-399 puan aralığında 2 saniye', () {
      expect(
          GameEngine.spawnIntervalForScore(300), const Duration(seconds: 2));
      expect(
          GameEngine.spawnIntervalForScore(399), const Duration(seconds: 2));
    });

    test('400 ve üzeri puanda 1 saniye', () {
      expect(
          GameEngine.spawnIntervalForScore(400), const Duration(seconds: 1));
      expect(
          GameEngine.spawnIntervalForScore(999), const Duration(seconds: 1));
    });
  });
}
