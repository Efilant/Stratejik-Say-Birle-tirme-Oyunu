import 'package:flutter_test/flutter_test.dart';
import 'package:stratejik_sayi_birlestirme/logic/move_score_calculator.dart';

void main() {
  group('MoveScoreCalculator — PDF Bölüm 5 puan tablosu', () {
    test('her rakam için sabit puan değeri', () {
      expect(MoveScoreCalculator.pointsForBlockValue(1), 1);
      expect(MoveScoreCalculator.pointsForBlockValue(2), 2);
      expect(MoveScoreCalculator.pointsForBlockValue(3), 3);
      expect(MoveScoreCalculator.pointsForBlockValue(4), 5);
      expect(MoveScoreCalculator.pointsForBlockValue(5), 7);
      expect(MoveScoreCalculator.pointsForBlockValue(6), 9);
      expect(MoveScoreCalculator.pointsForBlockValue(7), 12);
      expect(MoveScoreCalculator.pointsForBlockValue(8), 15);
      expect(MoveScoreCalculator.pointsForBlockValue(9), 20);
    });

    test('geçersiz rakam 0 puan verir', () {
      expect(MoveScoreCalculator.pointsForBlockValue(0), 0);
      expect(MoveScoreCalculator.pointsForBlockValue(10), 0);
    });

    test('seçilen blokların puan değerlerinin toplamı', () {
      expect(MoveScoreCalculator.totalForValues([4, 5]), 12); // 5+7
      expect(MoveScoreCalculator.totalForValues([8, 9]), 35); // 15+20
      expect(MoveScoreCalculator.totalForValues([1, 2, 3]), 6);
    });

    test('boş seçim 0 puan', () {
      expect(MoveScoreCalculator.totalForValues([]), 0);
    });

    test('formatBreakdown hamle detayını gösterir', () {
      expect(MoveScoreCalculator.formatBreakdown([3, 7, 9]), '3+12+20 = 35');
      expect(MoveScoreCalculator.formatBreakdown([]), '0');
    });
  });
}
