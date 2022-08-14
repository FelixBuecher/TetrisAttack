part of tetris_attack;

class NameView extends AbstractView {

  NameView() : super(querySelector('#name-page'));

  final InputElement _playerNameInput = querySelector('#name-input');
  final _playerNameButton = querySelector('#name-button');
  final _longerNameInfo = querySelector('#longer-name-info');

  /// Button to accept the player name.
  HtmlElement get playerNameButton => _playerNameButton;
  /// Used to display the player the information
  /// that his chosen name is too short.
  HtmlElement get longerNameInfo => _longerNameInfo;
  /// Used to get the player name.
  InputElement get playerNameInput => _playerNameInput;

  @override
  void togglePage() {
    _page.classes.toggle('toggle');
    _playerNameInput.value = '';
  }

  /// Used to toggle the information that the player name is too short.
  void toggleLongerNameInfo() {
    _longerNameInfo.classes.toggle('toggle');
  }
}