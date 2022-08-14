part of tetris_attack;

class GameModeView extends AbstractView {

  GameModeView() : super(querySelector('#game-selection-page'));

  final _puzzleButton = querySelector('#left-selection');
  final _survivalButton = querySelector('#right-selection');
  final _backButton = querySelector('#mode-mainmenu-button');

  /// Button to get back to the index page.
  HtmlElement get backButton => _backButton;
  /// Button to select puzzle mode.
  HtmlElement get puzzleButton => _puzzleButton;
  /// Button to select survival mode.
  HtmlElement get survivalButton => _survivalButton;
}