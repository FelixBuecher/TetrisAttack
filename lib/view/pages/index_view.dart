part of tetris_attack;

class IndexView extends AbstractView {

  IndexView() : super(querySelector('#index-page'));

  final _startButton = querySelector('#start-button');
  final _highScoreButton = querySelector('#highscore-button');
  final _ruleButton = querySelector('#rule-button');
  final _changeNameButton = querySelector('#change-name-button');

  /// Button to get to the game mode selection.
  HtmlElement get startButton => _startButton;
  /// Button to show the highscores.
  HtmlElement get highScoreButton => _highScoreButton;
  /// Button to show the rules of the game.
  HtmlElement get ruleButton => _ruleButton;
  /// Button to do a name change.
  HtmlElement get changeNameButton => _changeNameButton;
}