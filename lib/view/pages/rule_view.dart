part of tetris_attack;

class RuleView extends AbstractView {

  RuleView() : super(querySelector('#rule-page'));

  final _backButton = querySelector('#rule-page > .back-button');

  /// Button to get back to the index page.
  HtmlElement get backButton => _backButton;
}