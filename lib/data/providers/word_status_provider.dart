import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/word_status_model.dart';

class WordStatusProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await initDatabase();
    return database!;
  }

  static String tableName = 'wordStatus';
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databaseUserAccount = 'userAccount';
  static const String databaseWord = 'word';
  static const String databaseLearned = 'learned';
  static const String databaseLiked = 'liked';


  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'wordStatus.sqlite'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE $tableName($databaseId INTEGER PRIMARY KEY AUTOINCREMENT, $databaseUserAccount TEXT, $databaseWord TEXT, $databaseLearned INTEGER, $databaseLiked INTEGER, UNIQUE($databaseUserAccount, $databaseWord))",
        );
      },
      version: 1,
    );

  static Future<void> addWordStatus({required WordStatus status}) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      status.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> addWordsStatus({required List<WordStatus> statuses}) async {
    final Database db = await getDBConnect();
    for ( var status in statuses ){
      await db.insert(
        tableName,
        status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
    
  static Future<WordStatus> getWordStatus({required String word, required String account}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseUserAccount = ? and $databaseWord = ?",
      whereArgs: [account, word]
    );
    return WordStatus(
      id: maps[0][databaseId],
      userAccount: maps[0][databaseUserAccount],
      word: maps[0][databaseWord],
      learned: (maps[0][databaseLearned] == 1) ? true : false,
      liked: (maps[0][databaseLiked] == 1) ? true : false
    );
  }

  static Future<List<WordStatus>> getWordsStatus({required List<String> words, required String account}) async {
    final Database db = await getDBConnect();
    List<WordStatus> statuses = [];
    for (var word in words){
      List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: ["*"],
        where: "$databaseUserAccount = ? and $databaseWord = ?",
        whereArgs: [account, word]
      );
      statuses.add(
        WordStatus(
          id: maps[0][databaseId],
          userAccount: maps[0][databaseUserAccount],
          word: maps[0][databaseWord],
          learned: (maps[0][databaseLearned] == 1) ? true : false,
          liked: (maps[0][databaseLiked] == 1) ? true : false
        )
      );
    }
    return statuses;
  }

  static Future<void> updateWordStatus({required WordStatus status}) async {
    final Database db = await getDBConnect();
    await db.update(
      tableName,
      status.toMapWithId(),
      where: "$databaseId = ?",
      whereArgs: [status.id]
    );
  }

  static Future<void> closeDb() async {
    database = null;
    await deleteDatabase( 
      join(await getDatabasesPath(), 'wordStatus.sqlite')
    );
  }
}
