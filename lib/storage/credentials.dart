import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

final TextEditingController usernameController =
    TextEditingController(text: "");
final TextEditingController passwordController =
    TextEditingController(text: "");

const _KEY_USERNAME = "KEY_USERNAME";
const _KEY_PASSWORD = "KEY_PASSWORD";
const _KEY_ACCESSKEY = "KEY_ACCESSKEY";
const _KEY_SECRETKEY = "KEY_SECRETKEY";
const _KEY_REMEMBER_ME = "KEY_REMEMBER_ME";
const _KEY_DEVICE_ID = "KEY_DEVICE_ID";
const _KEY_SUBSCRIBER = "KEY_SUBSCRIBER";
const _KEY_SUBSCRIPTION_EXPIRES_AT = "KEY_SUBSCRIPTION_EXPIRES_AT";

Future<void> readFromStorage() async {
  usernameController.text = await UserName.get() ?? "";
  passwordController.text = await Password.get() ?? "";
}

Future<bool> isLoggedIn() async {
  return await _storage.read(key: _KEY_ACCESSKEY) != null;
}

class _BaseSecureStorage {
  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> set(String key, String? value) async {
    _storage.write(key: key, value: value);
  }
}

class AccessKey {
  static String key = _KEY_ACCESSKEY;

  static Future<String> get() async {
    var data = await _BaseSecureStorage.get(key);
    if (data == null) {
      throw Exception("AccessKey is null");
    }
    return data;
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class SecretKey {
  static String key = _KEY_SECRETKEY;

  static Future<String> get() async {
    var data = await _BaseSecureStorage.get(key);
    if (data == null) {
      throw Exception("SecretKey is null");
    }
    return data;
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class UserName {
  static String key = _KEY_USERNAME;

  static Future<String?> get() async {
    return await _BaseSecureStorage.get(key);
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class Password {
  static String key = _KEY_PASSWORD;

  static Future<String?> get() async {
    return await _BaseSecureStorage.get(key);
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class RememberMe extends _BaseSecureStorage {
  static String key = _KEY_REMEMBER_ME;

  static Future<bool> get() async {
    var data = await _BaseSecureStorage.get(key);
    return data == true.toString();
  }

  static Future<void> set(bool? value) async {
    _storage.write(key: key, value: (value == null) ? null : value.toString());
  }
}

class DeviceId extends _BaseSecureStorage {
  static String key = _KEY_DEVICE_ID;

  static Future<String?> get() async {
    return await _BaseSecureStorage.get(key);
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class Subscriber extends _BaseSecureStorage {
  static String key = _KEY_SUBSCRIBER;

  static Future<String?> get() async {
    return await _BaseSecureStorage.get(key);
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}

class SubscriptionExpiresAt extends _BaseSecureStorage {
  static String key = _KEY_SUBSCRIPTION_EXPIRES_AT;

  static Future<String?> get() async {
    return await _BaseSecureStorage.get(key);
  }

  static Future<void> set(String? value) async {
    _BaseSecureStorage.set(key, value);
  }
}
