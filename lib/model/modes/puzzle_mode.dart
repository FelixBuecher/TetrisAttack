part of tetris_attack;

/// Implementation of the puzzle mode model.
class PuzzleMode extends AbstractGame {

  /// The loaded level for the puzzlemode.
  final Map<String, dynamic> _level;
  int _swapRemaining;

  /// Creates a new puzzlemode game, needs a level that will be loaded once the game starts.
  PuzzleMode(this._level) : super(Gamemode.puzzle, Field(Gamemode.puzzle));

  /// Determines how many swaps are still left until the round is lost.
  int get swapRemaining => _swapRemaining;

  @override
  void startGame() {
    _swapRemaining = _level['moves'];
    _field.loadLevel(_level);
    _state = Gamestate.running;
  }

  /// Used to decrease the swaps that are left to clear a stage.
  void decreaseSwaps(int n) => _swapRemaining -= n;
}