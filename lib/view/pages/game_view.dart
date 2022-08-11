part of tetris_attack;

class GameView extends AbstractView {

  GameView() : super(querySelector('#game-page'));

  List<List<HtmlElement>> _field;
  final _backButton = querySelector('#pause-window > .back-button');
  final _puzzleBackButton = querySelector('#puzzle-window > .back-button');
  final _playingField = querySelector('#playing-field');
  final _score = querySelector('#current-score');
  final _scoreText = querySelector('#current-score-text');
  final _time = querySelector('#current-time');
  final _speed = querySelector('#current-speed');
  final _speedText = querySelector('#current-speed-text');
  final _pauseWindow = querySelector('#pause-window');
  final _puzzleWindow = querySelector('#puzzle-window');
  final _resetHint = querySelector('#reset-hint');

  /// Button to get back to the index page.
  HtmlElement get backButton => _backButton;
  /// Button to get back to the stage selection after a puzzle is completed.
  HtmlElement get puzzleBackButton => _puzzleBackButton;

  /// Used when a new game is started
  void startGame(game) {
    clearField();
    createField(game);
    updatePlayingField(game);
    updateScore(game);
    updateTime(game);
    updateSpeedLevel(game);
    setSpeedText(game);
    setScoreText(game);
  }

  /// Used to toggle the information
  /// that the game is currently paused.
  void togglePauseWindow() {
    _pauseWindow.classes.toggle('toggle');
  }

  /// Used to toggle the puzzle window to either show
  /// that the player has won or not.
  void togglePuzzleWindow(bool won) {
    _puzzleWindow.children.first.innerHtml = won ? 'GG WP go next' : 'You lost try again';
    _puzzleWindow.classes.toggle('toggle');
  }

  /// Used to update the current time visually.
  void updateTime(game) {
    _time.innerHtml = game.time.toString();
  }

  /// Used to update the current speed level visually.
  void updateSpeedLevel(game) {
    _speed.innerHtml = game.mode == Gamemode.survival ? game.speedLevel.toString() : game.swapRemaining.toString();
  }

  /// Method to setup the display name of either speed level if survival mode is selected,
  /// or swaps remaining, if puzzle mode is selected.
  void setSpeedText(game) {
    if(game.mode == Gamemode.survival) {
      _speedText.innerHtml = 'Speed lv.';
    } else {
      _speedText.innerHtml = 'Swaps left';
    }
  }

  /// Method to setup the display name of either the score
  /// or the blocks that are left on the field.
  void setScoreText(game) {
    if(game.mode == Gamemode.survival) {
      _scoreText.innerHtml = 'Score';
    } else {
      _scoreText.innerHtml = 'Stones left';
    }
  }

  /// Used to update the current score visually.
  void updateScore(game) {
    _score.innerHtml = game.mode == Gamemode.survival ? game.score.toString() : game.field.blockCount.toString();
  }

  /// Used to animate the swapping of blocks.
  void animatedSwapping(game) {
    var col = game.field.selector.posCol;
    var row = game.field.selector.posRow;
    _field[row][col].classes.add('swapleft');
    _field[row][col - 1].classes.add('swapright');
  }

  /// Method to initialize the playing field, then saving it in a local table.
  void createField(game) {
    // Get the playing field from game
    final blocks = game.field.blocks;
    var table = '';
    for (var row = 0; row < blocks.length; row++) {
      // Each row starts with a tr.
      table += '<tr>';
      for(var col = 0; col < blocks[row].length; col++) {
        // Each cell in that row gets an id with its position.
        final pos = 'field_${row}_$col';
        // Initialize each cell as empty, and set their id to the positional id created before.
        table += "<td id='$pos' class='$emptyBlockS'></td>";
      }
      // End a row with a closing tr.
      table += '</tr>';
    }
    // Apply the just created table to the game page.
    _playingField.innerHtml = table;
    _field = List.generate(gameRows, (row) =>
        List.generate(gameCols, (col) =>
            _playingField.querySelector('#field_${row}_$col'), growable: false),
        growable: false
    );
    _resetHint.innerHtml = game.mode == Gamemode.puzzle ? 'Press R to reset the puzzle!' : 'Press shift to spawn new blocks!';
  }

  /// Used to update the game visually.
  void updatePlayingField(game) {
    final blocks = game.field.blocks;
    final selector = game.field.selector;
    final removedBlocks = game.field.removedBlocks;

    for (var row = 0; row < blocks.length; row++) {
      for (var col = 0; col < blocks[row].length; col++) {
        final type = blocks[row][col];
        _field[row][col].classes.clear();
        _field[row][col].classes.add(type);
      }
    }
    // Add selector to the field based on the game position, not doing it before because keyframes.
    _field[selector.posRow][selector.posCol].classes.add(selectorSRight);
    _field[selector.posRow][selector.posCol - 1].classes.add(selectorSLeft);

    for (var block in removedBlocks) {
      _field[block.first][block.second].classes.add('removeblock');
    }
  }

  /// Clears the playing field table after a lost game, so it can be initialized for another game.
  void clearField() {
    _playingField.innerHtml = '';
  }
}