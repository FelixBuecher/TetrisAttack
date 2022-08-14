part of tetris_attack;

class PuzzleController extends AbstractController {

  Map<String, dynamic> _level;
  StreamSubscription<KeyboardEvent> _resetListener;
  var _seenTutorial = false;

  PuzzleController(View view, LocalStorage localStorage) : super(view, localStorage) {
    _initWindowNavigation();
  }

  /// Method that needs to be called before a game gets started, to load the playing field.
  void setLevel(Map<String, dynamic> level) {
    _level = level;
  }

  @override
  void startGame() {
    _game = PuzzleMode(_level);
    _game.startGame();
    _view.gameView.startGame(_game);
    if(_level['name'] == 'level1' && !_seenTutorial) {
      _startTutorial(0);
      _seenTutorial = true;
    } else {
      _initControls();
      _initTimer();
    }
  }

  @override
  void loseGame() {
    super.loseGame();
    _view.stageSelectView.togglePage();
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
    _stop();
    // Updating the player level list
    if(won) {
      _view.gameView.toggleRetryPuzzleButton();
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
        if(_view.gameView.puzzleWindow.classes.contains('toggle')) _view.gameView.togglePuzzleWindow(false);
        _stop();
        startGame();
      }
    });
  }

  /// Method to stop the game.
  void _stop() {
    _gameSpeed.cancel();
    _time.cancel();
    _keyListener.cancel();
    _resetListener.cancel();
    _game.stopGame();
  }

  /// Method to start the tutorial if the first stage was chosen.
  void _startTutorial(int n) {
    if(n >= 5) {
      _initControls();
      _initTimer();
    }
    _view.gameView.toggleTutorial(n);
    _view.gameView.tutorialButton.onClick.first.then((event) {
      _startTutorial(n + 1);
    });
  }

  /// Method to init the extra buttons for the puzzle mode,
  /// which are shown in the pause or finish window.
  void _initWindowNavigation() {
    // Button to retry a failed puzzle.
    _view.gameView.puzzleRetryButton.onClick.listen((event) {
      _view.gameView.puzzleRetryButton.blur();
      _view.gameView.togglePuzzleWindow(false);
      _stop();
      startGame();
    });

    // Button to take the player back to the stage select page, from the game pause window.
    _view.gameView.pauseStageButton.onClick.listen((event) {
      _view.gameView.pauseStageButton.blur();
      _view.gameView.togglePauseWindow();
      _view.gameView.toggleRetryPuzzleButton();
      _view.gameView.toggleStageButton();
      _view.gameView.togglePage();
      _stop();
      _view.stageSelectView.togglePage();
    });
  }
}