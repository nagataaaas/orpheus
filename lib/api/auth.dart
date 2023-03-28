import 'dart:convert';

import 'package:orpheus_client/api/common.dart' as common;
import 'package:orpheus_client/exeptions.dart';
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

const uuid = Uuid();

const apiPrefix = '${common.apiPrefix}/Auth';

Future<String> getDeviceId() async {
  String? id = await credentials.DeviceId.get();
  if (id == null) {
    try {
      id = await PlatformDeviceId.getDeviceId;
    } catch (e) {
      id = null;
    }
    id ??= uuid.v4();
    await credentials.DeviceId.set(id);
  }
  return id;
}

class Auth {
  static Future<bool> login(String username, String password) async {
    const url = '$apiPrefix/Login';
    Map<String, dynamic> json;
    try {
      http.Response response = await common.post(
          url,
          {
            "username": username,
            "password": password,
            "deviceId": await getDeviceId(),
          },
          false);
      if (response.statusCode != 200) {
        return false;
      }
      json = jsonDecode(response.body);
    } on NeedLoginException {
      return false;
    } on FormatException {
      // failed to parse json
      return false;
    }
    String accessKey = json["accesskey"];
    String secretKey = json["secretkey"];
    String subscriber = json["subscriber"];
    String subscriptionExpiresAt = json["subscriptionExpires"];

    credentials.AccessKey.set(accessKey);
    credentials.SecretKey.set(secretKey);
    credentials.Subscriber.set(subscriber);
    credentials.SubscriptionExpiresAt.set(subscriptionExpiresAt);
    return true;
  }

  static Future<void> logout() async {
    await common.post("/auth/logout", {}, true);
  }

  static Future<bool> extend() async {
    const url = '$apiPrefix/Extend';
    Map<String, dynamic> json;
    try {
      http.Response response = await common.get(
        url,
        {
          'Content-Length': '0',
          'Connection': 'keep-alive',
        },
        true,
      );
      if (response.statusCode != 200) {
        return false;
      }
      json = jsonDecode(response.body);
    } on NeedLoginException {
      return false;
    } on FormatException {
      // failed to parse json
      return false;
    }
    String accessKey = json["accesskey"];
    String secretKey = json["secretkey"];
    String subscriber = json["subscriber"];
    String subscriptionExpiresAt = json["subscriptionExpires"];

    credentials.AccessKey.set(accessKey);
    credentials.SecretKey.set(secretKey);
    credentials.Subscriber.set(subscriber);
    credentials.SubscriptionExpiresAt.set(subscriptionExpiresAt);
    return true;
  }
}
