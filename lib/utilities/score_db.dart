import 'dart:async';
import 'package:flutter_food_for_thought/utilities/user_scores.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Database _db;

  DB._(this._db);
  //load or create the databse
  static Future<DB> loadDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'scores_database.db'),
      onCreate: (db, version) {
        //probably not needed, but works with transaction
        db.transaction((transacn) {
          return transacn.execute(
              "CREATE TABLE scores(id INTEGER PRIMARY KEY AUTOINCREMENT, scoreDate INTEGER, userScore INTEGER, gameid TEXT, userName TEXT)");
        });
      },
      version: 1,
    );
    //run these lines to delete the database and create
    //a new one:
    
    // database.execute("DROP TABLE IF EXISTS scores");
    // database.execute(
    //     "CREATE TABLE scores(id INTEGER PRIMARY KEY AUTOINCREMENT, scoreDate INTEGER, userScore INTEGER, gameid TEXT, userName TEXT)");

    return DB._(database);
  }

  //function to add scores, same scores to be added aswell
  //
  //called when: game is finished with a score greater than 0
  void addScore(Score score) async {
    await _db.insert(
      'scores',
      score.toMap(),
      //you are able to get the same score more than once,
      //so both should be saved and not overwritten
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  //function to delete the scores that dont make the top 10 scores
  //
  //called when:
  //the scores are already mapped
  void deleteScore() async {
      //(dont know how to do this in sqlite, so used raw SQL and 
      //dont want to change it anymore as it is prone to errors)
    await _db.rawDelete("DELETE FROM scores WHERE id NOT IN (SELECT id FROM scores ORDER BY userScore DESC LIMIT 10 )");
  }

  //to be able to call up scores from a specific game
  //if more games were to be added
  Future<List<Score>> scores([String gameid]) async {
    List<Map<String, dynamic>> maps;
    if (gameid != null) {
      maps = await _db.query('scores',
          where: 'scores.gameid = ?',
          whereArgs: [gameid],
          orderBy: "userScore DESC");
    } else {
      //order the table by userScore, top scores at the top
      maps = await _db.query('scores', orderBy: "userScore DESC");
      //delete called after map is made so your most recent score
      //can still be seen once if it didnt make top 10
      //(while testing, screen could fit 12 scores)
      deleteScore();
    }
  //return the correct format of the score map, with the row/ranking
    return maps.map((row) => Score.fromMap(row)).toList();
  }
}
