import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/api/albums.dart' as albumsApi;
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orpheus_client/components/home_album_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

Future<Map<String, dynamic>> getPaginate(
    BuildContext context, int page, perPage) async {
  http.Response? response;
  Map<String, dynamic>? resultJson;
  try {
    response = await albumsApi.Albums.get(page: page, perPage: perPage);
    resultJson = jsonDecode(response.body);
  } on NeedLoginException {
    Navigator.pushReplacementNamed(context, '/login');
  } on FormatException {
    log("[HomeScreen.getPaginate] Failed to parse json. status code: ${response?.statusCode}, body: ${response?.body}");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("ロードに失敗しました"),
      backgroundColor: Colors.red,
    ));
  }
  return resultJson!;
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 1;
  int perPage = 20;
  late int totalPage;

  bool isFirstLoading = true;
  bool isLoadingMore = false;

  List<HomeAlbumItem> albums = [];
  Set<String> albumIds = {};

  late ScrollController _scrollController;

  Future<void> _loadFirst() async {
    if (!isFirstLoading) return;
    Map<String, dynamic> resultJson =
        await getPaginate(context, currentPage, perPage);
    setState(() {
      totalPage = resultJson['totalpages'];
      pushAlbums(resultJson['tracklists']);
      isFirstLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore) return;
    if (currentPage < totalPage) {
      setState(() {
        currentPage++;
        isLoadingMore = true;
      });
      Map<String, dynamic> resultJson =
          await getPaginate(context, currentPage, perPage);
      setState(() {
        pushAlbums(resultJson['tracklists']);
        isLoadingMore = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.extentAfter < 300) {
          _loadMore();
        }
      });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void pushAlbums(List<dynamic> jsons) {
    for (var json in jsons) {
      if (albumIds.contains(json['id'])) continue;
      albumIds.add(json['id']);
      albums.add(HomeAlbumItem.fromJson(json));
    }
  }

  void insertAlbumsHead(List<dynamic> jsons) {
    for (var json in jsons) {
      if (albumIds.contains(json['id'])) continue;
      albumIds.add(json['id']);
      albums.insert(0, HomeAlbumItem.fromJson(json));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scrollbar(
      child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  centerTitle: true,
                  title:
                      const Text("Home", style: TextStyle(color: Colors.black)),
                  pinned: true,
                  shape: const Border(
                      bottom: BorderSide(
                          color: Color.fromARGB(255, 231, 231, 231), width: 1)),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MyCupertinoPageRoute(
                                  builder: (context) => HomeSearchScreen(),
                                  settings: const RouteSettings(
                                      name: '/home/search')));
                        },
                        icon: const Icon(Icons.search_outlined,
                            color: Colors.black))
                  ],
                )
              ],
          body: isFirstLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    Map<String, dynamic> resultJson =
                        await getPaginate(context, 1, perPage);
                    setState(() {
                      insertAlbumsHead(resultJson['tracklists']);
                    });
                  },
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      ...albums,
                      if (isLoadingMore)
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Center(child: CircularProgressIndicator()))
                    ],
                  ),
                )),
    );
  }
}
