part of tetris_attack;

/// Controller class for the survival mode.
class SurvivalController extends AbstractController {

  /// The time interval after which new stones will be generated, this interval will get
  /// smaller and smaller as the game progresses to increase difficulty.
  StreamSubscription _newStoneSpeed;

  /// The interval in which [_newStoneSpeed] will be increased.
  StreamSubscription _speedLevel;

  /// API caller which is gotten from the page controller.
  final APICaller _apiCaller;

  Duration _currentNewStoneSpeed = newBlockSpeed;

  SurvivalController(View view, LocalStorage localStorage, this._apiCaller) : super(view, localStorage);

  @override
  void startGame() {
    _game = SurvivalMode();
    _game.startGame();
    _view.gameView.startGame(_game);
    _initControls();
    _initTimer();
  }

  @override
  void _loseGame() {
    super._loseGame();
    _speedLevel.cancel();
    _newStoneSpeed.cancel();
    _apiCaller.submitHighScore(_localStorage.loadUsername(), _localStorage.loadUniqueID(), _game.score);
    _view.loseView.loadStats(_game);
    _view.loseView.togglePage();
  }

  @override
  void _pauseGame() {
    super._pauseGame();
    _speedLevel.pause();
    _newStoneSpeed.pause();
  }

  @override
  void _resumeGame() {
    super._resumeGame();
    _speedLevel.resume();
    _newStoneSpeed.resume();
  }

  /// Method that is used to return to the index page.
  void _loseGameMainMenu() {
    super._loseGame();
    _speedLevel.cancel();
    _newStoneSpeed.cancel();
    _view.indexView.togglePage();
  }

  /// Updates the speed level the player is playing on.
  void _updateSpeedLevel() {
    _game.increaseSpeedLevel(1);
    _view.gameView.updateSpeedLevel(_game);
    _currentNewStoneSpeed *= speedIncrease;
    _newStoneSpeed.cancel();
    _newStoneSpeed = Stream.periodic(_currentNewStoneSpeed, (timer) {
      if(_game.state == Gamestate.running) _game.field.generateNewBlocks();
    }).listen((event) { });
  }

  @override
  void _initTimer() {
    super._initTimer();
    _speedLevel = Stream.periodic(speedLevelSpeed, (timer) {
      if(_game.state == Gamestate.running) _updateSpeedLevel();
    }).listen((event) { });

    _newStoneSpeed = Stream.periodic(newBlockSpeed, (timer) {
      if(_game.state == Gamestate.running) _game.field.generateNewBlocks();
    }).listen((event) { });
  }

  /// Method used to submit the scored highscore to the leaderboard,
  /// if the now scored score is higher than the all time high of the player.


  @override
  void _initControls() {
    super._initControls();
    // Button to take the player back to the index page.
    _mainMenuListener = _view.gameView.pauseBackButton.onClick.listen((event) {
      _view.gameView.pauseBackButton.blur();
      _view.gameView.togglePauseWindow();
      _mainMenuListener.cancel();
      _loseGameMainMenu();
    });
  }
}