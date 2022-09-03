part of tetris_attack;

/// Model of the game, holds the game logic.
abstract class AbstractGame {

  final Field _field;
  final Gamemode _mode;
  Gamestate _state;
  int _time  = 0;
  int _score = 0;

  /// Constructor, used to set the mode.
  AbstractGame(this._mode, this._field);

  /// The current state of the game.
  Gamestate get state => _state;
  /// The game mode.
  Gamemode get mode   => _mode;
  /// The playing field.
  Field get field     => _field;
  /// The currently played time in seconds.
  int get time        => _time;
  /// The current score of the player.
  int get score       => _score;

  /// Called when a new game gets started.
  void startGame();

  /// Called everytime the field should be updated.
  void updateGame() {
    field.updateField();
    if(field.scoreIncrease != 0) increaseScore(field.scoreIncrease);
    field.resetScoreIncrease();
    if(field.gameOver) stopGame();
  }

  /// Used to pause the game.
  void pauseGame() => _state = Gamestate.paused;

  /// Used to resume the game once its paused.
  void resumeGame() => _state = Gamestate.running;

  /// Used to set the current game state to stopped.
  void stopGame() => _state = Gamestate.lost;

  /// Used to increase the players current score.
  void increaseScore(int n) => _score += n;

  /// Used to increase the time spent playing in seconds.
  void increaseTime(int n) => _time += n;
}