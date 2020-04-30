import 'dart:async';
import 'package:flutter_food_for_thought/utilities/user_scores.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Future<Database> openDB() async {
//   final database = openDatabase(
//     join(await getDatabasesPath(), 'scores_database.db'),
//     onCreate: (db, version) {
//       return db.execute(
//         "CREATE TABLE scores(id INTEGER PRIMARY KEY AUTOINCREMENT, scoreDate TEXT, userScore INTEGER)",
//       );
//     },
//     version: 1,
//   );
//   return database;
// }

// Future<void> insertScore(Score score, final database) async {
//   final Database db = await database;

//   await db.insert(
//     'scores',
//     score.toMap(),
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }

// Future<List<Score>> scores(final database) async {
//   print("querying database...");
//   // Get a reference to the database.
//   final Database db = await database;

//   // Query the table for all The Dogs.
//   final List<Map<String, dynamic>> maps = await db.query('scores');

//   // Convert the List<Map<String, dynamic> into a List<Dog>.
//   return List.generate(maps.length, (i) {
//     return Score(
//       id: maps[i]['id'],
//       scoreDate: maps[i]['scoreDate'],
//       userScore: maps[i]['userScore'],
//     );
//   });
// }

// Future<void> updateScore(Score score, final database) async {
//   // Get a reference to the database.
//   final db = await database;

//   // Update the given Dog.
//   await db.update(
//     'scores',
//     score.toMap(),
//     // Ensure that the Dog has a matching id.
//     where: "id = ?",
//     // Pass the Dog's id as a whereArg to prevent SQL injection.
//     whereArgs: [score.id],
//   );
// }

// Future<void> deleteScore(int id, final database) async {
//   // Get a reference to the database.
//   final db = await database;

//   // Remove the Dog from the database.
//   await db.delete(
//     'scores',
//     // Use a `where` clause to delete a specific dog.
//     where: "id = ?",
//     // Pass the Dog's id as a whereArg to prevent SQL injection.
//     whereArgs: [id],
//   );
// }

// void manipulateDatabase(Score scoreObject, final database) async {
//   await insertScore(scoreObject, database);
//   print(await scores(database));
// }

class DB {
  Database _db;

  DB._(this._db);

  static Future<DB> loadDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'scores_database.db'),
      onCreate: (db, version) {
        return db.transaction((txn) {
          txn.execute(
              "CREATE TABLE scores(id INTEGER PRIMARY KEY AUTOINCREMENT, scoreDate INTEGER, userScore INTEGER, gameid TEXT, userName TEXT)");
        });
      },
      version: 1,
    );
    // database.execute("DROP TABLE IF EXISTS scores");
    // database.execute(
    //     "CREATE TABLE scores(id INTEGER PRIMARY KEY AUTOINCREMENT, scoreDate INTEGER, userScore INTEGER, gameid TEXT, userName TEXT)");

    return DB._(database);
  }

  void addScore(Score score) async {
    await _db.insert(
      'scores',
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  void updateScore(Score score) async {
    await _db.update(
      'scores',
      score.toMap(),
      where: "id = ?",
      whereArgs: [score.id],
    );
  }

  void deleteScore(int id) async {
    await _db.delete(
      'scores',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Score>> scores([int gameId]) async {
    List<Map<String, dynamic>> maps;
    if (gameId != null) {
      maps = await _db.query('scores',
          where: 'scores.gameid=?',
          whereArgs: [gameId],
          orderBy: "userScore DESC");
    } else {
      maps = await _db.query('scores', orderBy: "userScore DESC");
    }
    // final List<Map<String, dynamic>> maps = await _db.query('scores');
    return maps.map((row) => Score.fromMap(row)).toList();
  }
}
