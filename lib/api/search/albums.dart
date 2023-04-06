import 'dart:convert';
import 'dart:developer';

import 'package:orpheus_client/api/common.dart' as common;
import 'package:orpheus_client/components/search_album_paginate_item.dart';
import 'package:orpheus_client/exeptions.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

const uuid = Uuid();

const apiPrefix = '${common.apiPrefix}/Search/Album/';

class SearchAlbumsGetResponse {
  final List<SearchAlbumPaginateItem> albums;
  final int totalPages;

  SearchAlbumsGetResponse(this.albums, this.totalPages);
}

class SearchAlbums {
  static Future<SearchAlbumsGetResponse?> get(String query,
      {int page = 1, perPage = 20}) async {
    final String url = '$apiPrefix/${Uri.encodeFull(query.trim())}';

    Map<String, dynamic> json;
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
        log("[SearchAlbums.get] Something went wrong. status code: ${response.statusCode}, body: ${response.body}");
        throw TemporaryException;
      }
    } on NeedLoginException {
      log("[SearchAlbums.get] Need Login. status code: ${response?.statusCode}, body: ${response?.body}");
      throw NeedLoginException;
    }
    try {
      final json = jsonDecode(response.body);

      final albums = json['tracklists'] == null
          ? <SearchAlbumPaginateItem>[]
          : json['tracklists']
              .map((json) => SearchAlbumPaginateItem.fromJson(json))
              .toList()
              .cast<SearchAlbumPaginateItem>() as List<SearchAlbumPaginateItem>;
      final totalPages = json['totalpages'];
      return SearchAlbumsGetResponse(albums, totalPages);
    } on FormatException {
      log("[Albums.get] Failed to parse json. status code: ${response.statusCode}, body: ${response.body}");
    }
  }
}
