import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

class Album {
  static const tableName = "albums";

  final String id;
  final String artworkUrl;
  final String? category;
  final String? contributors; // json
  final String? label; // json
  final DateTime siteReleaseDate; // actually, it's date

  final String title;
  final String originalTitle;
  final List<Group> groups;

  Album({
    required this.id,
    required this.artworkUrl,
    required this.category,
    required this.contributors,
    required this.label,
    required this.siteReleaseDate,
    required this.title,
    required this.originalTitle,
    required this.groups,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      artworkUrl: json['artwork']['resource'],
      category: json['category'],
      contributors: jsonEncode({'value': json['contributors']}),
      label: jsonEncode(json['label']),
      siteReleaseDate: DateFormat("yyyy/MM/dd").parse(json['sitereleasedate']),
      title: json['title'],
      originalTitle: json['titleorig'],
      groups: Group.arrayFromJsons(
          json['tracks'].cast<Map<String, dynamic>>()
              as List<Map<String, dynamic>>,
          json['id']),
    );
  }

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

  final int id; // track.trackgroupid
  final String albumId;
  final String name;
  final String originalName;

  String contributors; // json

  int tracksCount;
  int duration;

  late List<Track> tracks;

  Group({
    required this.id,
    required this.albumId,
    required this.name,
    required this.originalName,
    required this.tracksCount,
    required this.contributors,
    required this.duration,
    required this.tracks,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        albumId TEXT NOT NULL,
        name TEXT NOT NULL,
        originalName TEXT NOT NULL,
        tracksCount INTEGER NOT NULL default 1,
        contributors TEXT NOT NULL,
        duration INTEGER NOT NULL
      );
      CREATE INDEX ${tableName}_albumId ON $tableName (albumId);
    ''';
  }

  static List<Group> arrayFromJsons(
      List<Map<String, dynamic>> jsons, String albumId) {
    final groupsMap = <int, Group>{};
    jsons.forEach((e) {
      final g = Group.fromJson(e, albumId);
      if (groupsMap.containsKey(g.id)) {
        final group = groupsMap[g.id]!;
        group.tracksCount++;
        group.duration += g.duration;
        group.tracks.add(g.tracks.first);
        List<dynamic> contr = (jsonDecode(group.contributors)['value'] +
                jsonDecode(g.contributors)['value'])
            .toSet()
            .toList();
        group.contributors = jsonEncode({'value': contr});
      } else {
        groupsMap[g.id] = g;
      }
    });
    return groupsMap.values.toList();
  }

  factory Group.fromJson(Map<String, dynamic> json, String albumId) {
    final track = Track.fromJson(json, albumId);
    return Group(
      id: (json['trackgroupid'] as double).toInt(),
      albumId: albumId,
      name: json['group'],
      originalName: json['grouporig'],
      tracksCount: 1,
      contributors: jsonEncode({'value': json['contributors']}),
      duration: track.duration,
      tracks: [track],
    );
  }
}

class Track {
  static const tableName = "tracks";

  final int id; // track.trackid
  final String albumId;
  final int groupId;
  final String genre;
  final String title;
  final String originalTitle;

  final String? resource; // mp4 url
  final String contributors; // json

  final int duration;

  Track({
    required this.id,
    required this.albumId,
    required this.groupId,
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
        id INTEGER PRIMARY KEY,
        albumId TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        genre TEXT NOT NULL,
        title TEXT NOT NULL,
        originalTitle TEXT NOT NULL,
        resource TEXT NOT NULL,
        contributors TEXT NOT NULL,
        duration INTEGER NOT NULL
      );
      CREATE INDEX ${tableName}_albumId ON $tableName (albumId);
      CREATE INDEX ${tableName}_groupId ON $tableName (groupId);
    ''';
  }

  factory Track.fromJson(Map<String, dynamic> json, String albumId) {
    // parse hh:mm:ss duration to seconds
    final parsedDuration =
        json['duration'].split(':').map((e) => int.parse(e)).toList();
    final duration = parsedDuration[0] * 60 * 60 +
        parsedDuration[1] * 60 +
        parsedDuration[2];
    return Track(
      id: json['trackid'],
      albumId: albumId,
      groupId: (json['trackgroupid'] as double).toInt(),
      genre: json['genre'],
      title: json['title'],
      originalTitle: json['titleorig'],
      resource: json['audio']?['resource'],
      contributors: jsonEncode({'value': json['contributors']}),
      duration: duration,
    );
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
