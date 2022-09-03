part of tetris_attack;

/// Controller class for the puzzle mode.
class PuzzleController extends AbstractController {

  final Map<String, dynamic> _level;
  StreamSubscription<KeyboardEvent> _resetListener;
  StreamSubscription<MouseEvent> _stageSelectListener;
  StreamSubscription<MouseEvent> _retryListener;
  StreamSubscription<MouseEvent> _finishPuzzleListener;

  PuzzleController(View view, LocalStorage localStorage, this._level) : super(view, localStorage);

  @override
  void startGame() {
    _game = PuzzleMode(_level);
    _game.startGame();
    _view.gameView.startGame(_game);
    if(_level['name'] == 'level1' && _localStorage.checkTutorial()) {
      _startTutorial(0);
    } else {
      _initControls();
      _initTimer();
    }
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
    _stopGame();
    // Updating the player level list
    if(won) {
      _view.gameView.toggleRetryPuzzleButton();
      var playerLevel = _localStorage.loadLevels();
      playerLevel[_level['name']] = true;
      _view.stageSelectView.updateStageSelection(playerLevel);
      _localStorage.saveLevels(playerLevel);
    }
    _initLoseControls();
    _view.gameView.togglePuzzleWindow(won);
  }

  /// Method that is called when the user won the puzzle to give controls over the shown buttons.
  void _initLoseControls() {
    _retryListener = _view.gameView.puzzleRetryButton.onClick.listen((event) {
      _retryListener.cancel();
      _finishPuzzleListener.cancel();
      _stopGame();
      _view.gameView.puzzleRetryButton.blur();
      _view.gameView.togglePuzzleWindow(false);
      startGame();
    });

    // Button that is pressed when the player won a puzzle.
    _finishPuzzleListener = _view.gameView.puzzleBackButton.onClick.listen((event) {
      _finishPuzzleListener.cancel();
      _retryListener.cancel();
      _view.gameView.puzzleBackButton.blur();
      _view.gameView.togglePuzzleWindow(false);
      _view.gameView.togglePage();
      if(!_view.gameView.puzzleRetryButton.classes.contains('show-button')) _view.gameView.toggleRetryPuzzleButton();
      _view.gameView.toggleStageButton();
      _view.gameView.toggleRetryPuzzleButton();
      _view.stageSelectView.togglePage();
    });
  }

  @override
  void _initControls() {
    super._initControls();
    _resetListener = window.onKeyDown.listen((event) {
      if(event.keyCode == primaryResetPuzzle && _game.state == Gamestate.running) {
        _stopGame();
        startGame();
      }
    });

    // Button to take the player back to the stage select page, from the game pause window.
    _stageSelectListener = _view.gameView.pauseStageButton.onClick.listen((event) {
      _stopGame();
      _view.gameView.pauseStageButton.blur();
      _view.gameView.togglePauseWindow();
      _view.gameView.toggleRetryPuzzleButton();
      _view.gameView.toggleStageButton();
      _view.gameView.togglePage();
      _view.stageSelectView.togglePage();
    });

    // Button to take the player back to the index page.
    _mainMenuListener = _view.gameView.pauseBackButton.onClick.listen((event) {
      _stopGame();
      _view.gameView.pauseBackButton.blur();
      _view.gameView.togglePauseWindow();
      _view.gameView.toggleRetryPuzzleButton();
      _view.gameView.toggleStageButton();
      _view.gameView.togglePage();
      _view.gameView.clearField();
      _view.indexView.togglePage();
    });
  }

  /// Method to stop the game.
  void _stopGame() {
    _gameSpeed.cancel();
    _time.cancel();
    _keyListener.cancel();
    _resetListener.cancel();
    _stageSelectListener.cancel();
    _mainMenuListener.cancel();
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
}