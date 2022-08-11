part of tetris_attack;

/// Selector, the small two field wide entity that the player controls.
class Selector {

  int _posCol;
  int _posRow;

  /// Creates the selector for the player, needs a start position of column and row, column needs to be >= 1.
  Selector(this._posCol, this._posRow);

  /// Moves the selector on the column position by y and on the row position by x.
  void moveSelector(int x, int y) {
    _posCol += y;
    _posRow += x;
  }

  /// Stores the column position that the selector is currently on, this stores the right side of the selector!
  int get posCol => _posCol;
  /// Stores the row position the selector is currently on.
  int get posRow => _posRow;
}