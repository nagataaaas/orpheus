import 'dart:developer';

import 'package:orpheus_client/api/common.dart' as common;
import 'package:orpheus_client/exeptions.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

const uuid = Uuid();

const apiPrefix = '${common.apiPrefix}/Search/Album/';

class SearchAlbums {
  static Future<http.Response> get(String query,
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
    return response;
  }
}
