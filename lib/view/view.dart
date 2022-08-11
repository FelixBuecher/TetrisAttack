part of tetris_attack;

/// This class is basically just a collection
/// of all views that I use on my site,
/// so that I only need to create one object in my controller.
class View {
  final IndexView _indexView = IndexView();
  final GameView _gameView = GameView();
  final LoseView _loseView = LoseView();
  final GameModeView _gameModeView = GameModeView();
  final NameView _nameView = NameView();
  final HighScoreView _highScoreView = HighScoreView();
  final RuleView _ruleView = RuleView();
  final StageSelectView _stageSelectView = StageSelectView();

  IndexView get indexView => _indexView;
  GameView get gameView => _gameView;
  LoseView get loseView => _loseView;
  GameModeView get gameModeView => _gameModeView;
  NameView get nameView => _nameView;
  HighScoreView get highScoreView => _highScoreView;
  RuleView get ruleView => _ruleView;
  StageSelectView get stageSelectView => _stageSelectView;
}