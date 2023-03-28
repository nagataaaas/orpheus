import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

class Album {
  static const tableName = "albums";

  final String id;
  final String artworkUrl;
  final String category;
  final String contributors; // json
  final String labal; // json
  final DateTime siteReleaseDate; // actually, it's date

  final String title;
  final String originalTitle;

  Album({
    required this.id,
    required this.artworkUrl,
    required this.category,
    required this.contributors,
    required this.labal,
    required this.siteReleaseDate,
    required this.title,
    required this.originalTitle,
  });

  // factory Episode.fromJson(Map<String, dynamic> json) {
  //   return Episode(
  //     id: json['key'],
  //     title: json['name'],
  //     html: json['body'],
  //   );
  // }

  // factory Episode.fromDatabase(Map<String, dynamic> json) {
  //   return Episode(
  //     id: json['id'],
  //     title: json['title'],
  //     html: json['html'],
  //   );
  // }

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        artworkUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        contributors TEXT NOT NULL,
        labal TEXT NOT NULL,
        siteReleaseDate TEXT NOT NULL,
        title TEXT NOT NULL,
        originalTitle TEXT NOT NULL
      )
    ''';
  }
}

class Group {
  static const tableName = "track_groups";

  final String id; // track.trackgroupid
  final String name;
  final String originalName;

  final int tracksCount;
  final String contributors; // json

  final int duration;

  Group({
    required this.id,
    required this.name,
    required this.originalName,
    required this.tracksCount,
    required this.contributors,
    required this.duration,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        originalName TEXT NOT NULL,
        tracksCount INTEGER NOT NULL default 1,
        contributors TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''';
  }
}

class Track {
  static const tableName = "tracks";

  final String id; // track.trackid
  final String genre;
  final String title;
  final String originalTitle;

  final String resource; // mp4 url
  final String contributors; // json

  final int duration;

  Track({
    required this.id,
    required this.genre,
    required this.title,
    required this.originalTitle,
    required this.resource,
    required this.contributors,
    required this.duration,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        genre TEXT NOT NULL,
        title TEXT NOT NULL,
        originalTitle TEXT NOT NULL,
        resource TEXT NOT NULL,
        contributors TEXT NOT NULL,
        duration INTEGER NOT NULL
      )
    ''';
  }
}

// class DatabaseHelper {
//   static const _databaseName = "Naxos.db";
//   static const _databaseVersion = 1;

//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   static Database? _database;

//   Future<Database?> get database async {
//     if (_database != null) return _database;
//     _database = await _initDatabase();
//     return _database;
//   }

//   _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = "${documentsDirectory.path}/$_databaseName";

//     return await openDatabase(path,
//         version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute(Episode.createTableSql());
//   }
// }

// // argument
// //  - id: str
// // returns:
// //  bool: whether the episode is locally saved
// Future<bool> isEpisodeCached(String id) async {
//   var db = await DatabaseHelper.instance.database;
//   var result = await db!
//       .rawQuery("SELECT 1 FROM ${Episode.tableName} WHERE id = ?", [id]);
//   return result.isNotEmpty;
// }

// // argument
// //  - episode: Episode
// // returns:
// //  bool: save episode to SQLite and return true
// Future<bool> saveEpisode(Episode episode) async {
//   var db = await DatabaseHelper.instance.database;
//   await db!.insert(Episode.tableName, {
//     'id': episode.id,
//     'title': episode.title,
//     'html': episode.html,
//   });
//   return true;
// }

// // argument
// //  - id: str
// // returns:
// //  Episode: data of the episode
// Future<Episode> loadEpisode(String id) async {
//   var db = await DatabaseHelper.instance.database;
//   var result =
//       await db!.query(Episode.tableName, where: 'id = ?', whereArgs: [id]);
//   return Episode.fromDatabase(result.first);
// }
