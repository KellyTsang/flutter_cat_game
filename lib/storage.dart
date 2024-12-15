//add 20241213
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  final String name;
  final int score;

  Player({required this.name, required this.score});

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'],
    score: json['score'],
  );
}

class ScoreManager {
  static const String _storageKey = 'highScores';
  static const int maxPlayers = 5;

  static Future<List<Player>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresJson = prefs.getString(_storageKey);
    if (scoresJson == null) return [];

    List<dynamic> scoresList = jsonDecode(scoresJson);
    return scoresList.map((score) => Player.fromJson(score)).toList();
  }

  static Future<void> addScore(Player player) async {
    List<Player> highScores = await getHighScores();
    highScores.add(player);

    // Sort by score in descending order
    highScores.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top 5 scores
    if (highScores.length > maxPlayers) {
      highScores = highScores.sublist(0, maxPlayers);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(highScores.map((p) => p.toJson()).toList()),
    );
  }
}