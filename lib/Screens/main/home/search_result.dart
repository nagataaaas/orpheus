import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'package:orpheus_client/api/search/albums.dart' as albumsSearchApi;
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orpheus_client/components/search_album_item.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/storage/search_history.dart';

class HomeSearchResultArguments {
  final String searchText;
  HomeSearchResultArguments(this.searchText);
}

class HomeSearchResultScreen extends StatefulWidget {
  final HomeSearchResultArguments arguments;
  const HomeSearchResultScreen({super.key, required this.arguments});

  @override
  _HomeSearchResultScreenState createState() => _HomeSearchResultScreenState();
}

Future<Map<String, dynamic>> getPaginate(
    BuildContext context, String query, int page, perPage) async {
  http.Response? response;
  Map<String, dynamic>? resultJson;
  try {
    response = await albumsSearchApi.SearchAlbums.get(query,
        page: page, perPage: perPage);
    resultJson = jsonDecode(response.body);
  } on NeedLoginException {
    Navigator.pushReplacementNamed(context, '/login');
  } on FormatException {
    log("[HomeSearchResultScreen.getPaginate] Failed to parse json. status code: ${response?.statusCode}, body: ${response?.body}");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("ロードに失敗しました"),
      backgroundColor: Colors.red,
    ));
  }
  return resultJson!;
}

class _HomeSearchResultScreenState extends State<HomeSearchResultScreen> {
  String _searchText = '';
  bool isFirstLoading = true;
  bool isLoadingMore = false;

  int currentPage = 1;
  int perPage = 20;
  late int totalPage;

  List<SearchAlbumItem> albums = [];
  Set<String> albumIds = {};

  late ScrollController _scrollController;

  Future<void> _loadFirst() async {
    if (!isFirstLoading) return;
    Map<String, dynamic> resultJson =
        await getPaginate(context, _searchText, currentPage, perPage);
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
          await getPaginate(context, _searchText, currentPage, perPage);
      print(resultJson);
      setState(() {
        pushAlbums(resultJson['tracklists']);
        isLoadingMore = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchText = widget.arguments.searchText;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.extentAfter < 300) {
          _loadMore();
        }
      });

    _loadFirst();
  }

  void pushAlbums(List<dynamic> jsons) {
    for (var json in jsons) {
      if (albumIds.contains(json['id'])) continue;
      albumIds.add(json['id']);
      albums.add(SearchAlbumItem.fromJson(json));
    }
  }

  // TODO: searchとページ統合
  // TODO: Stackする

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                centerTitle: true,
                // search text input in title
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding:
                        const EdgeInsets.only(left: 40, bottom: 7, right: 10),
                    title: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: _searchText),
                          onTap: () => {
                            Navigator.of(context).push(
                              MyCupertinoPageRoute(
                                  builder: (context) => HomeSearchScreen(
                                      arguments:
                                          HomeSearchArguments(_searchText)),
                                  settings: const RouteSettings(
                                      name: '/home/search/result')),
                            )
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "曲名・人名・アルバム名",
                              suffixIcon: GestureDetector(
                                  onTap: () => {
                                        Navigator.of(context).push(
                                          MyCupertinoPageRoute(
                                              builder: (context) =>
                                                  HomeSearchScreen(
                                                      arguments:
                                                          HomeSearchArguments(
                                                              '')),
                                              settings: const RouteSettings(
                                                  name: '/home/search/result')),
                                        )
                                      },
                                  child: const Icon(Icons.clear,
                                      color: Colors.black))),
                        ),
                      ),
                    )),
                pinned: true,
                shape: const Border(
                    bottom: BorderSide(
                        color: Color.fromARGB(255, 231, 231, 231), width: 1)),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: isFirstLoading
              ? const Center(
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()))
              : Scrollbar(
                  child: Stack(children: [
                    ListView(
                      controller: _scrollController,
                      children: [
                        ...albums,
                        if (isLoadingMore)
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 50),
                              child: Center(child: CircularProgressIndicator()))
                      ],
                    )
                  ]),
                ),
        ));
  }
}
