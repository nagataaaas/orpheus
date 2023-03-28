import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InputHistoryData {
  String value;
  DateTime createdAt;

  InputHistoryData({required this.value, required this.createdAt});

  InputHistoryData.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        createdAt = DateTime.parse(json['createdAt']);

  Map<String, dynamic> toJson() => {
        'value': value,
        'createdAt': createdAt.toIso8601String(),
      };
}

class SearchHistory {
  static const String _key = 'searchHistory';
  static const int _limit = 30;

  static Future<List<InputHistoryData>> get() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_key);
    if (json == null) {
      return [];
    }
    final list =
        json.map((e) => InputHistoryData.fromJson(jsonDecode(e))).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<bool> add(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_key);
    if (json == null) {
      return prefs.setStringList(_key, [
        jsonEncode(InputHistoryData(
          value: data,
          createdAt: DateTime.now(),
        ))
      ]);
    }
    final list =
        json.map((e) => InputHistoryData.fromJson(jsonDecode(e))).toList();

    // if exists, update createdAt
    final index = list.indexWhere((e) => e.value == data);
    if (index != -1) {
      list[index].createdAt = DateTime.now();
    } else {
      list.add(InputHistoryData(
        value: data,
        createdAt: DateTime.now(),
      ));
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (list.length > _limit) {
      list.removeRange(_limit, list.length);
    }
    return prefs.setStringList(
        _key, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<bool> removeKey(InputHistoryData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_key);
    if (json == null) {
      return false;
    }
    final encoded = jsonEncode(data.toJson());
    return prefs.setStringList(_key, json.where((e) => e != encoded).toList());
  }

  static Future<bool> touch(InputHistoryData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_key);
    if (json == null) {
      return false;
    }
    final list =
        json.map((e) => InputHistoryData.fromJson(jsonDecode(e))).toList();
    final index = list.indexWhere((e) => e.value == data.value);
    if (index == -1) {
      return false;
    }
    list[index].createdAt = DateTime.now();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return prefs.setStringList(
        _key, list.map((e) => jsonEncode(e.toJson())).toList());
  }
}
