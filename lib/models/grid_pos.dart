/// [Esma] tarafından hazırlanan grid koordinat modeli.
/// Matristeki bir hücrenin konumunu tutar ve seçim zincirinde kullanılır.
class GridPos {
  final int row;
  final int col;

  const GridPos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}
