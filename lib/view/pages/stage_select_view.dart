part of tetris_attack;

class StageSelectView extends AbstractView {

  StageSelectView() : super(querySelector('#stage-selection-page')) {
    _createStageSelection();
  }

  final _selectionArea = querySelector('#selection-area');
  final _backButton = querySelector('#stage-selection-page > .back-button');
  List<HtmlElement> _stageSelectionButtons;

  /// Button to get back to the index page.
  HtmlElement get backButton => _backButton;
  /// List of the buttons that the player can press to select a puzzle.
  List<HtmlElement> get stageSelectionButtons => _stageSelectionButtons;

  /// Used to create the puzzle game selection
  void _createStageSelection() {
    var divElements = '';
    for(var i = 1; i < puzzleLevelCount + 1; i++) {
      var id = 'level' + i.toString();
      divElements += "<div id='$id' class='stage-selection'><p>Level $i</p></div>";
    }
    var stringmulti = sqrt(puzzleLevelCount).round();
    _selectionArea.style.gridTemplateColumns = 'auto ' * stringmulti;
    _selectionArea.innerHtml = divElements;
    _stageSelectionButtons = List.generate(puzzleLevelCount, (index) => _selectionArea.querySelector('#level' + (index + 1).toString()), growable: false);
  }

  /// Used to update the status of the puzzles (cleared or not) if the puzzle page is opened.
  void updateStageSelection(Map<String, bool> playerLevel) {
    for(var i = 1; i < puzzleLevelCount + 1; i++) {
      _stageSelectionButtons[i - 1].classes.clear();
      _stageSelectionButtons[i - 1].classes.add('stage-selection');
      if(playerLevel['level$i']) _stageSelectionButtons[i - 1].classes.add('clear');
    }
  }
}