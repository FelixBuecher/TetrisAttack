part of tetris_attack;

/// Controller of the page, holds game controllers and the logic to the page navigation.
class PageController {

  /// Used to locally store the username, so that the user does not have to type it everytime.
  final LocalStorage _localStorage = LocalStorage();

  /// The dedicated view that the controller gets his input from.
  final View _view = View();

  /// Controller for the survival mode.
  SurvivalController _survivalController;

  /// Controller for the puzzle mode.
  PuzzleController _puzzleController;

  /// Saves the currently started game mode.
  Gamemode _currentMode;

  /// Constructor for the Controller, initialises the index page navigation.
  PageController() {
    _puzzleController = PuzzleController(_view, _localStorage);
    _survivalController = SurvivalController(_view, _localStorage);
    _checkIfPlayerHasName();
    _initPageNavigation();
  }

  /// Used to check if the player has already played this game before, if so skip the naming page, else show the naming page first.
  void _checkIfPlayerHasName() {
    var playerName = _localStorage.loadUsername();
    if(playerName == null) {
      _view.nameView.togglePage();
      _localStorage.createUniqueID();
    } else {
      _view.indexView.togglePage();
    }
  }

  Future<Map<String, dynamic>> _loadLevel(String level) async {
    var response = await http.get(Uri.http(window.location.host, 'res/level/$level.json'));
    Map<String, dynamic> parameters = jsonDecode(response.body);
    return parameters;
  }

  /// Used to give the buttons to navigate the index page, listeners and functions.
  void _initPageNavigation() {
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////       INDEX PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to start a new game.
    _view.indexView.startButton.onClick.listen((event) {
      _view.indexView.startButton.blur();
      _view.indexView.togglePage();
      _view.gameModeView.togglePage();
    });

    // Button to show the highscores.
    _view.indexView.highScoreButton.onClick.listen((event) async {
      _view.indexView.highScoreButton.blur();
      _view.indexView.togglePage();
      _view.highScoreView.initPage();
      _view.highScoreView.togglePage();
      try {
        var ingressUrl = window.location.host.replaceFirst('webapp', 'rest');
        var response =  await http.get(Uri.http(ingressUrl, '/highscore'));
        if (response.statusCode != 200) throw Exception('${response.statusCode}');
        Map<String, dynamic> data = jsonDecode(response.body);
        _view.highScoreView.loadHighscores(data);
      } catch(_) {
        try {
          var localUrl = (window.location.hostname + ':$restPort');
          var response =  await http.get(Uri.http(localUrl, '/highscore'));
          if (response.statusCode != 200) throw Exception('${response.statusCode}');
          Map<String, dynamic> data = jsonDecode(response.body);
          _view.highScoreView.loadHighscores(data);
        } catch(_) {
          _view.highScoreView.loadHighscores(null);
        }
      }
    });

    // Button to show the rules of the game.
    _view.indexView.ruleButton.onClick.listen((event) {
      _view.indexView.ruleButton.blur();
      _view.indexView.togglePage();
      _view.ruleView.togglePage();
    });

    // Button to show the name giving page again.
    _view.indexView.changeNameButton.onClick.listen((event) {
      _view.indexView.changeNameButton.blur();
      _view.indexView.togglePage();
      _view.nameView.togglePage();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////     GAMEMODE  PAGE     ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to start the puzzle mode.
    _view.gameModeView.puzzleButton.onClick.listen((event) {
      _view.gameModeView.puzzleButton.blur();
      _view.stageSelectView.updateStageSelection(_localStorage.loadLevels());
      _view.gameModeView.togglePage();
      _view.stageSelectView.togglePage();
    });

    // Button to start the survival mode.
    _view.gameModeView.survivalButton.onClick.listen((event) {
      _view.gameModeView.survivalButton.blur();
      _view.gameModeView.togglePage();
      _view.gameView.togglePage();
      _currentMode = Gamemode.survival;
      _survivalController.startGame();
    });

    // Button in the game selection page to return to the index page.
    _view.gameModeView.backButton.onClick.listen((event) {
      _view.gameModeView.backButton.blur();
      _view.gameModeView.togglePage();
      _view.indexView.togglePage();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////       GAME  PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button that is pressed when the player won a puzzle.
    _view.gameView.puzzleBackButton.onClick.listen((event) {
      _view.gameView.puzzleBackButton.blur();
      _view.gameView.togglePuzzleWindow(false);
      _view.gameView.togglePage();
      if(!_view.gameView.puzzleRetryButton.classes.contains('show-button')) _view.gameView.toggleRetryPuzzleButton();
      _view.gameView.toggleStageButton();
      _view.gameView.toggleRetryPuzzleButton();
      _view.stageSelectView.togglePage();
    });

    // Button to take the player back to the index page, from the game page.
    _view.gameView.pauseBackButton.onClick.listen((event) {
      _view.gameView.pauseBackButton.blur();
      _view.gameView.togglePauseWindow();
      if(_currentMode == Gamemode.survival) {
        _survivalController.loseGameMainMenu();
      } else {
        _view.gameView.toggleRetryPuzzleButton();
        _view.gameView.toggleStageButton();
        _puzzleController.loseGameMainMenu();
      }
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////     HIGHSCORE PAGE     ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to take the player back to the index page, from the highscore page.
    _view.highScoreView.backButton.onClick.listen((event) {
      _view.highScoreView.backButton.blur();
      _view.highScoreView.togglePage();
      _view.indexView.togglePage();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////       RULE  PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to take the player back to the index page, from the rule page.
    _view.ruleView.backButton.onClick.listen((event) {
      _view.ruleView.backButton.blur();
      _view.ruleView.togglePage();
      _view.indexView.togglePage();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////       LOSE  PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to take the player back to the index page, from the lose page.
    _view.loseView.backButton.onClick.listen((event) {
      _view.loseView.backButton.blur();
      _view.loseView.togglePage();
      _view.indexView.togglePage();
    });

    // Button to start a new game instantly, from the lose page only in endless mode.
    _view.loseView.tryAgainButton.onClick.listen((event) {
      _view.loseView.tryAgainButton.blur();
      _view.loseView.togglePage();
      _view.gameView.togglePage();
      _currentMode = Gamemode.survival;
      _survivalController.startGame();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////      STAGE  PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Player clicked on one of the puzzle selection tiles.
    _view.stageSelectView.stageSelectionButtons.forEach((element) {
      element.onClick.listen((event) async {
        element.blur();
        var level = await _loadLevel(element.id);
        _view.stageSelectView.togglePage();
        _puzzleController.setLevel(level);
        _currentMode = Gamemode.puzzle;
        _view.gameView.togglePage();
        _view.gameView.toggleRetryPuzzleButton();
        _view.gameView.toggleStageButton();
        _puzzleController.startGame();
      });
    });

    // Button to get back to the main menu from the stage selection.
    _view.stageSelectView.backButton.onClick.listen((event) {
      _view.stageSelectView.backButton.blur();
      _view.stageSelectView.togglePage();
      _view.indexView.togglePage();
    });

    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////       NAME  PAGE       ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    // Button to confirm the players name.
    _view.nameView.playerNameButton.onClick.listen((event) {
      _view.nameView.playerNameButton.blur();
      var name = _view.nameView.playerNameInput.value.replaceAll(' ', '');
      if(name.length < 3) {
        if(!_view.nameView.longerNameInfo.classes.contains('toggle')) _view.nameView.toggleLongerNameInfo();
      } else {
        _localStorage.saveUsername(name);
        _view.nameView.togglePage();
        _view.indexView.togglePage();
      }
    });
  }
}