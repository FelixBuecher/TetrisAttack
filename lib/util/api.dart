part of tetris_attack;

/// This class is used to handle all the api calls that I do inside of the game.
class APICaller {

  /// Method used to fetch the highscores from the database.
  Future<Map<String, dynamic>> fetchHighScore() async {
    try {
      var ingressUrl = window.location.host.replaceFirst('webapp', 'rest');
      var response =  await http.get(Uri.http(ingressUrl, '/highscore'));
      if (response.statusCode != 200) throw Exception('${response.statusCode}');
      Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch(_) {
      try {
        var localUrl = (window.location.hostname + ':$restPort');
        var response =  await http.get(Uri.http(localUrl, '/highscore'));
        if (response.statusCode != 200) throw Exception('${response.statusCode}');
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } catch(_) {
        return null;
      }
    }
  }

  /// Method that can be called to make a database entry for the player
  /// with his unique id, name and score.
  void submitHighScore(String name, String uid, int score) async {
    // First try at the university deployment
    try {
      var ingressUrl = window.location.host.replaceFirst('webapp', 'rest');
      // Check if player already has high score.
      var highscore = await _checkHighScore(ingressUrl, uid);
      if(score < highscore) score = highscore;
      // Post the higher high score to the database
      _postData(ingressUrl, uid, name, score);

    } catch(_) {
      // Try on localhost with the specified port.
      try {
        var localUrl = (window.location.hostname + ':$restPort');
        var highscore = await _checkHighScore(localUrl, uid);
        if(score < highscore) score = highscore;
        _postData(localUrl, uid, name, score);
      } catch(_) {}
    }
  }

  /// Method to check if the player already has a higher high score than the
  /// one he just got.
  Future<int> _checkHighScore(var url, String uid) async {
    try {
      var response =  await http.get(Uri.http(url, '/highscore').replace(
          queryParameters: {
            'uid': uid
          }
      ));
      // return the found high score.
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return double.parse(data.values.first).round();
      }
      // return 0 if there was no high score or there was no connection.
      return 0;
    } catch(_) {
      return 0;
    }
  }

  /// Method to post highscores to the database.
  void _postData(var url, String uid, String name, int score) async {
    await http.post(
        Uri.http(url, '/highscore'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: <String, String>{
          'uid': uid,
          'name': name,
          'score': score.toString()
        }
    );
  }
}