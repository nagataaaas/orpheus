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
  List<Group> groups;

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
          json['id'],
          json['title'],
          json['artwork']['resource']),
    );
  }

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        artworkUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        contributors TEXT NOT NULL,
        label TEXT NOT NULL,
        siteReleaseDate TEXT NOT NULL,
        title TEXT NOT NULL,
        originalTitle TEXT NOT NULL
      )
    ''';
  }

  factory Album.fromDatabase(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      artworkUrl: json['artworkUrl'],
      category: json['category'],
      contributors: json['contributors'],
      label: json['label'],
      siteReleaseDate: DateTime.parse(json['siteReleaseDate']),
      title: json['title'],
      originalTitle: json['originalTitle'],
      groups: [],
    );
  }
}

class Group {
  static const tableName = "track_groups";

  final int id; // track.trackgroupid
  final String albumId;
  final String albumTitle;
  final String artworkUrl;
  final String name;
  final String originalName;

  String contributors; // json

  int get tracksCount => tracks.length;
  int duration;

  List<Track> tracks;
  bool get actAsTrack => tracksCount == 1;

  Group({
    required this.id,
    required this.albumId,
    required this.albumTitle,
    required this.artworkUrl,
    required this.name,
    required this.originalName,
    required this.contributors,
    required this.duration,
    required this.tracks,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        albumId TEXT NOT NULL,
        albumTitle TEXT NOT NULL,
        artworkUrl TEXT NOT NULL,
        name TEXT NOT NULL,
        originalName TEXT NOT NULL,
        contributors TEXT NOT NULL,
        duration INTEGER NOT NULL
      );
      CREATE INDEX ${tableName}_albumId ON $tableName (albumId);
    ''';
  }

  static List<Group> arrayFromJsons(List<Map<String, dynamic>> jsons,
      String albumId, albumTitle, artworkUrl) {
    final groupsMap = <int, Group>{};
    for (var e in jsons) {
      final g = Group.fromJson(e, albumId, albumTitle, artworkUrl);
      if (groupsMap.containsKey(g.id)) {
        final group = groupsMap[g.id]!;
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
    }
    return groupsMap.values.toList();
  }

  factory Group.fromJson(
      Map<String, dynamic> json, String albumId, albumTitle, artworkUrl) {
    final track = Track.fromJson(json, albumId, albumTitle, artworkUrl);
    return Group(
      id: (json['trackgroupid'] as double).toInt(),
      albumId: albumId,
      albumTitle: albumTitle,
      artworkUrl: artworkUrl,
      name: json['group'],
      originalName: json['grouporig'],
      contributors: jsonEncode({'value': json['contributors']}),
      duration: track.duration,
      tracks: [track],
    );
  }

  factory Group.fromDatabase(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      albumId: json['albumId'],
      albumTitle: json['albumTitle'],
      artworkUrl: json['artworkUrl'],
      name: json['name'],
      originalName: json['originalName'],
      contributors: json['contributors'],
      duration: json['duration'],
      tracks: [],
    );
  }
}

class Track {
  static const tableName = "tracks";

  final int id; // track.trackid
  final String albumId;
  final String albumTitle;
  final String artworkUrl;
  final int groupId;
  final String groupName;
  final String genre;
  final String title;
  final String originalTitle;

  final String? resource; // mp4 url
  final String contributors; // json

  final int duration;

  Track({
    required this.id,
    required this.albumId,
    required this.albumTitle,
    required this.artworkUrl,
    required this.groupId,
    required this.groupName,
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
        albumTitle TEXT NOT NULL,
        artworkUrl TEXT NOT NULL,
        groupId INTEGER NOT NULL,
        groupName TEXT NOT NULL,
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

  factory Track.fromJson(
      Map<String, dynamic> json, String albumId, albumTitle, artworkUrl) {
    // parse hh:mm:ss duration to seconds
    final parsedDuration =
        json['duration'].split(':').map((e) => int.parse(e)).toList();
    final duration = parsedDuration[0] * 60 * 60 +
        parsedDuration[1] * 60 +
        parsedDuration[2];
    return Track(
      id: json['trackid'],
      albumId: albumId,
      albumTitle: albumTitle,
      artworkUrl: artworkUrl,
      groupId: (json['trackgroupid'] as double).toInt(),
      groupName: json['group'],
      genre: json['genre'],
      title: json['title'],
      originalTitle: json['titleorig'],
      resource: json['audio']?['resource'],
      contributors: jsonEncode({'value': json['contributors']}),
      duration: duration,
    );
  }

  factory Track.fromDatabase(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      albumId: json['albumId'],
      albumTitle: json['albumTitle'],
      artworkUrl: json['artworkUrl'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      genre: json['genre'],
      title: json['title'],
      originalTitle: json['originalTitle'],
      resource: json['resource'],
      contributors: json['contributors'],
      duration: json['duration'],
    );
  }
}

class DatabaseHelper {
  static const _databaseName = "Naxos.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}/$_databaseName";

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(Album.createTableSql());
    await db.execute(Group.createTableSql());
    await db.execute(Track.createTableSql());
  }

  static setDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}/$_databaseName";
    await deleteDatabase(path);
    _database = await openDatabase(path, version: _databaseVersion,
        onCreate: (Database db, int version) async {
      await db.execute(Album.createTableSql());
      await db.execute(Group.createTableSql());
      await db.execute(Track.createTableSql());
      await db.execute(Playlist.createTableSql());
      await db.execute(Playlist.createFirstMylist());
      await db.execute(PlaylistTrack.createTableSql());
    });

    return _database;
  }
}

// argument
//  - id: str
// returns:
//  bool: whether the album is locally saved
Future<bool> isAlbumCached(String id) async {
  var db = await DatabaseHelper.instance.database;
  var result =
      await db!.rawQuery("SELECT 1 FROM ${Album.tableName} WHERE id = ?", [id]);
  return result.isNotEmpty;
}

// argument
//  - album: Album
// returns:
//  bool: save album to SQLite and return true
Future<bool> saveAlbum(Album album) async {
  var db = await DatabaseHelper.instance.database;
  await db!.insert(Album.tableName, {
    'id': album.id,
    'artworkUrl': album.artworkUrl,
    'category': album.category,
    'contributors': album.contributors,
    'label': album.label,
    'siteReleaseDate': album.siteReleaseDate.toIso8601String(),
    'title': album.title,
    'originalTitle': album.originalTitle,
  });
  await saveGroups(album.groups);
  return true;
}

Future<bool> saveGroups(List<Group> groups) async {
  var db = await DatabaseHelper.instance.database;
  var batch = db!.batch();
  for (var g in groups) {
    batch.insert(Group.tableName, {
      'id': g.id,
      'albumId': g.albumId,
      'albumTitle': g.albumTitle,
      'artworkUrl': g.artworkUrl,
      'name': g.name,
      'originalName': g.originalName,
      'contributors': g.contributors,
      'duration': g.duration,
    });
    await saveTracks(g.tracks);
  }
  await batch.commit();
  return true;
}

Future<bool> saveTracks(List<Track> tracks) async {
  var db = await DatabaseHelper.instance.database;
  var batch = db!.batch();
  for (var t in tracks) {
    batch.insert(Track.tableName, {
      'id': t.id,
      'albumId': t.albumId,
      'albumTitle': t.albumTitle,
      'artworkUrl': t.artworkUrl,
      'groupId': t.groupId,
      'groupName': t.groupName,
      'genre': t.genre,
      'title': t.title,
      'originalTitle': t.originalTitle,
      'resource': t.resource,
      'contributors': t.contributors,
      'duration': t.duration,
    });
  }
  await batch.commit();
  return true;
}

// argument
//  - id: str
// returns:
//  Album: data of the album
Future<Album> loadAlbum(String id, {bool withGroups = true}) async {
  var db = await DatabaseHelper.instance.database;
  var result =
      await db!.query(Album.tableName, where: 'id = ?', whereArgs: [id]);
  final album = Album.fromDatabase(result.first);
  if (!withGroups) return album;
  album.groups = await loadGroups(album.id);
  album.groups.sort((a, b) => a.id.compareTo(b.id));
  return album;
}

Future<List<Group>> loadGroups(String albumId, {bool withTracks = true}) async {
  var db = await DatabaseHelper.instance.database;
  var result = await db!
      .query(Group.tableName, where: 'albumId = ?', whereArgs: [albumId]);
  final groups = Future.wait(result.map((e) async {
    final group = Group.fromDatabase(e);
    if (!withTracks) return group;
    group.tracks = await loadTracks(group.id);
    return group;
  }).toList());
  return groups;
}

Future<Group> loadGroup(int groupId, {bool withTracks = true}) async {
  var db = await DatabaseHelper.instance.database;
  var result =
      await db!.query(Group.tableName, where: 'id = ?', whereArgs: [groupId]);
  final group = Group.fromDatabase(result.first);
  if (!withTracks) return group;
  group.tracks = await loadTracks(group.id);
  return group;
}

Future<List<Track>> loadTracks(int groupId) async {
  var db = await DatabaseHelper.instance.database;
  var result = await db!
      .query(Track.tableName, where: 'groupId = ?', whereArgs: [groupId]);
  final tracks = result.map((e) => Track.fromDatabase(e)).toList();
  tracks.sort((a, b) => a.id.compareTo(b.id));
  return tracks;
}

Future<Track> loadTrack(int trackId) async {
  var db = await DatabaseHelper.instance.database;
  var result =
      await db!.query(Track.tableName, where: 'id = ?', whereArgs: [trackId]);
  final track = Track.fromDatabase(result.first);
  return track;
}

class Playlist {
  static const tableName = "playlists";

  int? id;
  String title;
  DateTime createdAt;

  Playlist({
    this.id,
    required this.title,
    required this.createdAt,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''';
  }

  static String createFirstMylist() {
    return '''
      INSERT INTO $tableName (id, title, createdAt)
      VALUES (1, 'とりあえずプレイリスト', '${DateTime.now().toUtc().toIso8601String()}');
    ''';
  }

  static Future<Playlist> createWithTitle(String title) async {
    var db = await DatabaseHelper.instance.database;
    await db!.insert(Playlist.tableName, {
      'title': title,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    var result = await db!
        .query(Playlist.tableName, orderBy: "createdAt DESC", limit: 1);
    return Playlist.fromDatabase(result.first);
  }

  factory Playlist.fromDatabase(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  static Future<Playlist> findById(int id) async {
    var db = await DatabaseHelper.instance.database;
    var result =
        await db!.query(Playlist.tableName, where: 'id = ?', whereArgs: [id]);
    return Playlist.fromDatabase(result.first);
  }
}

class PlaylistTrack {
  static const tableName = "playlist_tracks";

  int? id;
  int playlistId;
  String sourceId;
  String sourceType;
  DateTime createdAt;

  PlaylistTrack({
    this.id,
    required this.playlistId,
    required this.sourceId,
    required this.sourceType,
    required this.createdAt,
  });

  static String createTableSql() {
    return '''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId INTEGER NOT NULL,
        sourceId TEXT NOT NULL,
        sourceType TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''';
  }

  static Future<void> addToPlaylist(
      int playlistId, String sourceId, sourceType) async {
    var db = await DatabaseHelper.instance.database;
    await db!.insert(PlaylistTrack.tableName, {
      'playlistId': playlistId,
      'sourceId': sourceId,
      'sourceType': sourceType,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static Future<void> removeFromPlaylist(
      int playlistId, String sourceId, sourceType) async {
    var db = await DatabaseHelper.instance.database;
    await db!.delete(PlaylistTrack.tableName,
        where: 'playlistId = ? AND sourceId = ? AND sourceType = ?',
        whereArgs: [playlistId, sourceId, sourceType]);
  }

  static Future<List<PlaylistTrack>> loadPlaylistTracks(int playlistId) async {
    var db = await DatabaseHelper.instance.database;
    var result = await db!.query(PlaylistTrack.tableName,
        where: 'playlistId = ?', whereArgs: [playlistId]);
    final tracks = result.map((e) => PlaylistTrack.fromDatabase(e)).toList();
    tracks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return tracks;
  }

  factory PlaylistTrack.fromDatabase(Map<String, dynamic> json) =>
      PlaylistTrack(
        id: json['id'],
        playlistId: json['playlistId'],
        sourceId: json['sourceId'].toString(),
        sourceType: json['sourceType'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

Future<List<int>> playlistIdsHasItem(String sourceId, sourceType) async {
  var db = await DatabaseHelper.instance.database;
  var result = await db!.query(PlaylistTrack.tableName,
      where: 'sourceId = ? AND sourceType = ?',
      whereArgs: [sourceId, sourceType]);
  final ids = result.map((e) => e['playlistId'] as int).toList();
  return ids;
}

Future<List<Playlist>> loadPlaylists() async {
  var db = await DatabaseHelper.instance.database;
  var result = await db!.query(Playlist.tableName, orderBy: "createdAt ASC");
  final playlists = result.map((e) => Playlist.fromDatabase(e)).toList();
  return playlists;
}

Future<void> renamePlaylist(int id, String title) async {
  var db = await DatabaseHelper.instance.database;
  await db!.update(Playlist.tableName, {'title': title},
      where: 'id = ?', whereArgs: [id]);
}

Future<void> deletePlaylist(int id) async {
  var db = await DatabaseHelper.instance.database;
  await db!.delete(Playlist.tableName, where: 'id = ?', whereArgs: [id]);
  await db.delete(PlaylistTrack.tableName,
      where: 'playlistId = ?', whereArgs: [id]);
}
