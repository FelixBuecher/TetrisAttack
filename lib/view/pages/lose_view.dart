part of tetris_attack;

class LoseView extends AbstractView {

  LoseView() : super(querySelector('#lose-page'));

  final _tryAgainButton = querySelector('#lose-again-button');
  final _backButton     = querySelector('#lose-mainmenu-button');
  final _finalScore     = querySelector('#final-score');
  final _finalTime      = querySelector('#final-time');

  /// Button to get back to the index page.
  HtmlElement get backButton      => _backButton;
  /// Button to start another game.
  HtmlElement get tryAgainButton  => _tryAgainButton;

  /// Method to set the inner html of the final score and time to display it.
  void loadStats(game) {
    _finalScore.innerHtml = game.score.toString();
    _finalTime.innerHtml = game.time.toString();
  }
}