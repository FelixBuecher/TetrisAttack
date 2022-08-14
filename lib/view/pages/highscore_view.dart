part of tetris_attack;

class HighScoreView extends AbstractView {

  HighScoreView() : super(querySelector('#highscore-page'));

  final _table = querySelector('#highscore-table');
  final _backButton = querySelector('#highscore-mainmenu-button');
  final _noConnectionInfo = querySelector('#no-connection-info');
  final _loading = querySelector('#loading-image');

  /// Button to get back to the index page.
  HtmlElement get backButton => _backButton;

  /// Method used to load and display the highscores of the players, can either take a map or null.
  /// In case of a map, it displays the data as a toplist, in case of null, it displays an error message.
  /// Need to call initPage() first.
  void loadHighscores(Map<String, dynamic> data) async {
    if(data != null) {
      var table = '<tr class="first-row"><td>Rank</td><td>Playername</td><td>Score</td></tr>';
      for (var row = 0; row < data.length; row++) {
        final name = data.keys.elementAt(row);
        final score = data[name];
        final rank = row + 1;
        table += '<tr>';
        table += '<td>$rank.</td>';
        table += '<td>$name</td>';
        table += '<td>$score</td>';
        table += '</tr>';
      }
      _table.innerHtml = table;
      _noConnectionInfo.innerHtml = '';
      _table.style.display = '';
      _loading.style.display = 'none';
    } else {
      _noConnectionInfo.style.display = '';
      _noConnectionInfo.innerHtml = 'Please activate the rest deployment to get access to the highscores!';
      _table.innerHtml = '';
      _table.style.display = 'none';
      _loading.style.display = 'none';
    }
  }

  /// Called to clear the page and set it up for either loading / info or highscore display.
  void initPage() {
    _table.style.display = 'none';
    _noConnectionInfo.style.display = 'none';
    _loading.style.display = '';
  }
}