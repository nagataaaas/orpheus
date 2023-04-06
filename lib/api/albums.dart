import 'dart:convert';
import 'dart:developer';

import 'package:orpheus_client/api/common.dart' as common;
import 'package:orpheus_client/components/album_paginate_item.dart';
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;
import 'package:orpheus_client/storage/sqlite.dart';

class AlbumsGetResponse {
  final List<AlbumPaginateItem> albums;
  final int totalPages;

  AlbumsGetResponse(this.albums, this.totalPages);
}

class Albums {
  static Future<AlbumsGetResponse?> get({int page = 1, perPage = 20}) async {
    const url = '${common.apiPrefix}/Album';
    http.Response? response;
    try {
      response = await common.get(
          url,
          {
            "P": page.toString(),
            "PP": perPage.toString(),
          },
          true);
      if (response.statusCode != 200) {
        log("[Albums.get] Something went wrong. status code: ${response.statusCode}, body: ${response.body}");
        throw TemporaryException;
      }
    } on NeedLoginException {
      log("[Albums.get] Need Login. status code: ${response?.statusCode}, body: ${response?.body}");
      throw NeedLoginException;
    }
    try {
      final json = jsonDecode(response.body);
      final albums = json['tracklists']
          .map((json) => AlbumPaginateItem.fromJson(json))
          .toList()
          .cast<AlbumPaginateItem>() as List<AlbumPaginateItem>;
      final totalPages = json['totalpages'];
      return AlbumsGetResponse(albums, totalPages);
    } on FormatException {
      log("[Albums.get] Failed to parse json. status code: ${response.statusCode}, body: ${response.body}");
    }
  }

  static Future<Album?> show(String id) async {
    // await DatabaseHelper.setDatabase();
    if (await isAlbumCached(id)) {
      return await loadAlbum(id);
    }
    final url = '${common.apiPrefix}/Album/$id';
    Map<String, dynamic> json;
    http.Response? response;
    try {
      response = await common.get(url, {}, true);
      if (response.statusCode != 200) {
        log("[Albums.show] Something went wrong. status code: ${response.statusCode}, body: ${response.body}");
        throw TemporaryException;
      }
    } on NeedLoginException {
      log("[Albums.show] Need Login. status code: ${response?.statusCode}, body: ${response?.body}");
      throw NeedLoginException;
    }
    try {
      final json = jsonDecode(response.body);
      final album = Album.fromJson(json);
      saveAlbum(album);
      return album;
    } on FormatException catch (e) {
      log("[Albums.show] Failed to parse json. ${e.message}; status code: ${response.statusCode}, body: ${response.body}");
    }
  }
}
