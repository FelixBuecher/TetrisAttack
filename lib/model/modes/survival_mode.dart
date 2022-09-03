part of tetris_attack;

/// Implementation of the survival mode model.
class SurvivalMode extends AbstractGame {

  int _speedLevel = 1;

  SurvivalMode() : super(Gamemode.survival, Field(Gamemode.survival));

  /// The speed level will determine how fast new blocks will spawn.
  int get speedLevel => _speedLevel;

  @override
  void startGame() {
    field.initFirstBlocks(4);
    _state = Gamestate.running;
  }

  /// Used to increase the current speed level which increases the difficulty.
  void increaseSpeedLevel(int n) => _speedLevel += n;
}