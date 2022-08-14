part of tetris_attack;

abstract class AbstractController {

  /// The game model where the magic happens.
  var _game;

  /// The dedicated view that the controller gets his input from.
  final View _view;

  /// Local storage used for getting the players name
  final LocalStorage _localStorage;

  /// KeyListener to get keys pressed by the player.
  StreamSubscription<KeyboardEvent> _keyListener;

  /// The rate that the in game timer will be increased.
  StreamSubscription _time;

  /// The refresh rate that the view and the model will be updated.
  StreamSubscription _gameSpeed;

  AbstractController(this._view, this._localStorage);

  /// Called when a new game gets started, needs to be implemented in all game modes.
  void startGame();

  /// Called when losing the game, clears everything from the old game.
  void loseGame() {
    // Stopping the general timers.
    _gameSpeed.cancel();
    _time.cancel();
    // Unsubscribing from the KeyListener
    _keyListener.cancel();
    // Stopping the game
    _game.stopGame();
    // Hide the playing field and clear the table for the next games.
    _view.gameView.togglePage();
    _view.gameView.clearField();
  }

  /// Called when the player returns to the main menu from the pause window.
  void loseGameMainMenu() {
    _gameSpeed.cancel();
    _time.cancel();
    _keyListener.cancel();
    _game.stopGame();
    _view.gameView.togglePage();
    _view.gameView.clearField();
    _view.indexView.togglePage();
  }

  /// Called every [_time] interval, updates the model and the view.
  void _updateGame() {
    _game.updateGame();
    _view.gameView.updatePlayingField(_game);
    _view.gameView.updateScore(_game);
  }

  /// Method to pause the game and current timers.
  void _pauseGame() {
    _game.pauseGame();
    _gameSpeed.pause();
    _time.pause();
  }

  /// Method to resume the current game and timers.
  void _resumeGame() {
    _game.resumeGame();
    _gameSpeed.resume();
    _time.resume();
  }

  /// Updates the time that the player spent playing.
  void _updateTime() {
    _game.increaseTime(1);
    _view.gameView.updateTime(_game);
  }

  /// Initializes the game timers.
  void _initTimer() {
    _gameSpeed = Stream.periodic(gameSpeed, (timer) {
      if(_game.state == Gamestate.running) {
        _updateGame();
        _view.gameView.updateSpeedLevel(_game);
      } else {
        loseGame();
      }
    }).listen((event) { });

    _time = Stream.periodic(timeSpeed, (timer) {
      if(_game.state == Gamestate.running) _updateTime();
    }).listen((event) { });
  }

  /// Initializes the KeyListener and listens to inputs for the Selector.
  void _initControls() {
    _keyListener = window.onKeyDown.listen((event) {
      if(_game.state == Gamestate.running) {
        switch(event.keyCode) {
          case primaryUp:
          case secondaryUp:
            _game.field.moveSelector(0, -1);
            break;
          case primaryDown:
          case secondaryDown:
            _game.field.moveSelector(0, 1);
            break;
          case primaryLeft:
          case secondaryLeft:
            _game.field.moveSelector(-1, 0);
            break;
          case primaryRight:
          case secondaryRight:
            _game.field.moveSelector(1, 0);
            break;
          case primarySwap:
          case secondarySwap:
            if(!_game.field.blocksFalling || _game.mode == Gamemode.survival) {
              _game.field.swapBlocks();
              _view.gameView.animatedSwapping(_game);
              if(_game.mode == Gamemode.puzzle) _game.decreaseSwaps(1);
            }
            break;
          case primaryPushStones:
            if(_game.mode == Gamemode.survival) _game.field.generateNewBlocks();
            break;
          case primaryPauseGame:
            _view.gameView.togglePauseWindow();
            _pauseGame();
            break;
        }
      } else if(event.keyCode == primaryPauseGame) {
        _view.gameView.togglePauseWindow();
        _resumeGame();
      }
    });
  }
}