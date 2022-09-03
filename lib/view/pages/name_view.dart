part of tetris_attack;

class NameView extends AbstractView {

  NameView() : super(querySelector('#name-page'));

  final _playerNameInput  = querySelector('#name-input') as InputElement;
  final _playerNameButton = querySelector('#name-button');
  final _longerNameInfo   = querySelector('#longer-name-info');

  /// Button to accept the player name.
  HtmlElement get playerNameButton  => _playerNameButton;
  /// Used to display the player the information
  /// that his chosen name is too short.

  /// Used to get the player name.
  InputElement get playerNameInput  => _playerNameInput;

  @override
  void togglePage() {
    _page.classes.toggle('toggle');
    _playerNameInput.value = '';
  }

  /// Used to toggle the information that the player name is too short.
  void toggleLongerNameInfo() {
    if(!_longerNameInfo.classes.contains('toggle')) _longerNameInfo.classes.toggle('toggle');
  }
}