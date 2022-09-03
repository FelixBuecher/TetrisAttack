part of tetris_attack;

/// Controller of the page, holds the current game controller and the logic to the page navigation.
class PageController {

  /// Used to locally store the username, so that the user does not have to type it everytime.
  final LocalStorage _localStorage = LocalStorage();

  /// The dedicated view that the controller gets his input from.
  final View _view = View();

  /// Api caller to save to the database and load from it.
  final APICaller _apiCaller = APICaller();

  /// Current Game Controller
  var _currentController;

  /// Constructor for the Controller, initialises the index page navigation.
  PageController() {
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

  /// Method used to load a level from the site.
  Future<Map<String, dynamic>> _loadLevel(String level) async {
    var response = await http.get(Uri.http(window.location.host, 'res/level/$level.json'));
    Map<String, dynamic> parameters = jsonDecode(response.body);
    return parameters;
  }

  /// Called to initiate the current game controller to the mode that should be started.
  /// Needs a level if a puzzle mode gets started.
  void _initiateGame(Gamemode mode, {var level}) {
    switch(mode) {
      case Gamemode.survival:
        _currentController = SurvivalController(_view, _localStorage, _apiCaller);
        break;
      case Gamemode.puzzle:
        _currentController = PuzzleController(_view, _localStorage, level);
        break;
    }
    _currentController.startGame();
  }

  /// Used to setup the navigation for tha page.
  void _initPageNavigation() {
    _initIndexNav();
    _initNameNav();
    _initLoseNav();
    _initRuleNav();
    _initStageSelectionNav();
    _initHighScoreNav();
    _initGameModeSelectionNav();
  }

  /// Used to initiate the navigation for the index page.
  void _initIndexNav() {
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
      var data = await _apiCaller.fetchHighScore();
      _view.highScoreView.loadHighscores(data);
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
  }

  /// Used to initiate the navigation for the game mode selection page.
  void _initGameModeSelectionNav() {
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
      _initiateGame(Gamemode.survival);
    });

    // Button in the game selection page to return to the index page.
    _view.gameModeView.backButton.onClick.listen((event) {
      _view.gameModeView.backButton.blur();
      _view.gameModeView.togglePage();
      _view.indexView.togglePage();
    });
  }

  /// Used to initiate the navigation for the high score page.
  void _initHighScoreNav() {
    // Button to take the player back to the index page, from the highscore page.
    _view.highScoreView.backButton.onClick.listen((event) {
      _view.highScoreView.backButton.blur();
      _view.highScoreView.togglePage();
      _view.indexView.togglePage();
    });
  }

  /// Used to initiate the navigation for the rule page.
  void _initRuleNav() {
    // Button to take the player back to the index page, from the rule page.
    _view.ruleView.backButton.onClick.listen((event) {
      _view.ruleView.backButton.blur();
      _view.ruleView.togglePage();
      _view.indexView.togglePage();
    });
  }

  /// Used to initiate the navigation for the lose page.
  void _initLoseNav() {
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
      _initiateGame(Gamemode.survival);
    });
  }

  /// Used to initiate the navigation for the stage selection page.
  void _initStageSelectionNav() {
    // Player clicked on one of the puzzle selection tiles.
    _view.stageSelectView.stageSelectionButtons.forEach((element) {
      element.onClick.listen((event) async {
        element.blur();
        _view.stageSelectView.togglePage();
        var level = await _loadLevel(element.id);
        _initiateGame(Gamemode.puzzle, level: level);
        _view.gameView.togglePage();
        _view.gameView.toggleRetryPuzzleButton();
        _view.gameView.toggleStageButton();
      });
    });

    // Button to get back to the main menu from the stage selection.
    _view.stageSelectView.backButton.onClick.listen((event) {
      _view.stageSelectView.backButton.blur();
      _view.stageSelectView.togglePage();
      _view.indexView.togglePage();
    });
  }

  /// Used to initiate the navigation for the name page.
  void _initNameNav() {
    // Button that gets pressed when the name gets confirmed.
    _view.nameView.playerNameButton.onClick.listen((event) {
      _view.nameView.playerNameButton.blur();
      var name = _view.nameView.playerNameInput.value.replaceAll(' ', '');
      if(name.length < 3) {
        _view.nameView.toggleLongerNameInfo();
      } else {
        _localStorage.saveUsername(name);
        _view.nameView.togglePage();
        _view.indexView.togglePage();
      }
    });
  }
}