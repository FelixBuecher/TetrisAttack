part of tetris_attack;

/// Abstract class for the views so I
/// don't have to type the get method for each page.
abstract class AbstractView {

  final _page;

  AbstractView(this._page);

  /// Returns the whole page element.
  HtmlElement get page => _page;

  /// Used to toggle the page to either hide or show it.
  void togglePage() {
    _page.classes.toggle('toggle');
  }
}