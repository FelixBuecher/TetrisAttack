part of tetris_attack;

class LocalStorage {
  final Storage _storage = window.localStorage;
  final Random _rand = Random();

  /// Used to store the players name
  void saveUsername(String username) {
    _storage['username'] = username;
  }

  /// Used to load the players name from cache
  String loadUsername() {
    return _storage['username'];
  }

  /// Used to save the information if a puzzle level is completed
  void saveLevels(Map<String, bool> levelMap) {
    for(var i = 1; i < puzzleLevelCount + 1; i++) {
      _storage['level$i'] = levelMap['level$i'].toString();
    }
  }

  /// Used to load the map that holds information about the cleared puzzle levels.
  Map<String, bool> loadLevels() {
    var result = <String, bool>{};
    for(var i = 1; i < puzzleLevelCount + 1; i++) {
      if(_storage['level$i'] == null) _storage['level$i'] = 'false';
      result['level$i'] = _storage['level$i'].toLowerCase() == 'true';
    }
    return result;
  }

  /// Used to store the players unique id for scoring.
  void createUniqueID() {
    var uid = '';
    for(var i = 0; i < 20; i++) {
      uid += _rand.nextInt(9).toString();
    }
    _storage['uid'] = uid;
  }

  /// Used to load the players uid from cache
  String loadUniqueID() {
    return _storage['uid'];
  }

  /// Used to reset the username.
  void clearUsername() {
    _storage.remove('username');
  }

  /// Used to reset the levels.
  void clearLevels() {
    for(var i = 1; i < puzzleLevelCount + 1; i++) {
      _storage.remove('level$i');
    }
  }

  /// Used to reset everything but the unique id.
  void clear() {
    clearLevels();
    clearUsername();
  }
}