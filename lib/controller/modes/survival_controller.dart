part of tetris_attack;

class SurvivalController extends AbstractController {

  /// The time interval after which new stones will be generated, this interval will get
  /// smaller and smaller as the game progresses to increase difficulty.
  StreamSubscription _newStoneSpeed;

  /// The interval in which [_newStoneSpeed] will be increased.
  StreamSubscription _speedLevel;

  Duration _currentNewStoneSpeed = newBlockSpeed;

  SurvivalController(View view, LocalStorage localStorage) : super(view, localStorage);

  @override
  void startGame() {
    _game = SurvivalMode();
    _game.startGame();
    _view.gameView.startGame(_game);
    _initControls();
    _initTimer();
  }

  @override
  void loseGame(bool mainmenu) {
    super.loseGame(mainmenu);
    _speedLevel.cancel();
    _newStoneSpeed.cancel();
    if(mainmenu) {
      _view.indexView.togglePage();
    } else {
      _submitHighscore();
      _view.loseView.loadStats(_game);
      _view.loseView.togglePage();
    }
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
  void _submitHighscore() async {
    var name = _localStorage.loadUsername();
    var uid = _localStorage.loadUniqueID();
    var score = _game.score;
    try {
      var ingressUrl = window.location.host.replaceFirst('webapp', 'rest');
      var response =  await http.get(Uri.http(ingressUrl, '/highscore').replace(
          queryParameters: {
            'uid': uid
          }
      ));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        var highscore = double.parse(data.values.first).round();
        if(score < highscore) score = highscore;
      }

      await http.post(
          Uri.http(ingressUrl, '/highscore'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: <String, String>{
            'uid': uid,
            'name': name,
            'score': score.toString()
          }
      );

    } catch(_) {
      try {
        var localUrl = (window.location.hostname + ':$restPort');
        var response =  await http.get(Uri.http(localUrl, '/highscore').replace(
            queryParameters: {
              'uid': uid
            }
        ));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          var highscore = double.parse(data.values.first).round();
          if(score < highscore) score = highscore;
        }

        await http.post(
            Uri.http(localUrl, '/highscore'),
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: <String, String>{
              'uid': uid,
              'name': name,
              'score': score.toString()
            }
        );
      } catch(_) {}
    }
  }
}