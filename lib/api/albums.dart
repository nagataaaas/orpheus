import 'dart:developer';

import 'package:orpheus_client/api/common.dart' as common;
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;

class Albums {
  static Future<http.Response> get({int page = 1, perPage = 20}) async {
    const url = '${common.apiPrefix}/Album';
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
        log("[Albums.get] Something went wrong. status code: ${response.statusCode}, body: ${response.body}");
        throw TemporaryException;
      }
    } on NeedLoginException {
      log("[Albums.get] Need Login. status code: ${response?.statusCode}, body: ${response?.body}");
      throw NeedLoginException;
    }
    return response;
  }
}
