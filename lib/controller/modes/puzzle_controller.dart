part of tetris_attack;

class PuzzleController extends AbstractController {

  Map<String, dynamic> _level;
  StreamSubscription<KeyboardEvent> _resetListener;

  PuzzleController(View view, LocalStorage localStorage) : super(view, localStorage);

  /// Method that needs to be called before a game gets started, to load the playing field.
  void setLevel(Map<String, dynamic> level) {
    _level = level;
  }

  @override
  void startGame() {
    _game = PuzzleMode(_level);
    _game.startGame();
    _view.gameView.startGame(_game);
    _initControls();
    _initTimer();
  }

  @override
  void loseGame(bool mainmenu) {
    super.loseGame(mainmenu);
    mainmenu ? _view.indexView.togglePage() : _view.stageSelectView.togglePage();
  }

  @override
  void _updateGame() {
    super._updateGame();
    _view.gameView.updateSpeedLevel(_game);
    if(_game.field.blockCount > 0 && _game.swapRemaining <= 0 && !_game.field.blocksFalling) {
      _finishPuzzle(false);
    } else if(_game.field.blockCount == 0 && _game.swapRemaining >= 0) {
      _finishPuzzle(true);
    }
  }

  /// Method that is called when the players wins a puzzle, stops the game and displays a window to the player.
  void _finishPuzzle(bool won) {
    // Stopping the general timers.
    _gameSpeed.cancel();
    _time.cancel();
    // Unsubscribing from the KeyListener
    _keyListener.cancel();
    // Stopping the game
    _game.stopGame();
    // Updating the player level list
    if(won) {
      var playerLevel = _localStorage.loadLevels();
      playerLevel[_level['name']] = true;
      _view.stageSelectView.updateStageSelection(playerLevel);
      _localStorage.saveLevels(playerLevel);
    }
    _view.gameView.togglePuzzleWindow(won);
  }

  @override
  void _initControls() {
    super._initControls();
    _resetListener = window.onKeyDown.listen((event) {
      if(event.keyCode == primaryResetPuzzle && _game.state == Gamestate.running) {
        _gameSpeed.cancel();
        _time.cancel();
        _keyListener.cancel();
        _resetListener.cancel();
        startGame();
      }
    });
  }
}