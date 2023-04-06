import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'package:orpheus_client/api/search/albums.dart' as albumsSearchApi;
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orpheus_client/components/search_album_paginate_item.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/storage/search_history.dart';
import 'package:orpheus_client/styles.dart';
import 'navigation.dart' show HomeScreenChildBase;

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

Future<albumsSearchApi.SearchAlbumsGetResponse?> getPaginate(
    BuildContext context, String query, int page, perPage) async {
  late albumsSearchApi.SearchAlbumsGetResponse? result;
  try {
    result = await albumsSearchApi.SearchAlbums.get(query,
        page: page, perPage: perPage);
    if (result == null) {
      throw const FormatException();
    }
  } on NeedLoginException {
    Navigator.pushReplacementNamed(context, '/login');
  } on FormatException {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("ロードに失敗しました"),
      backgroundColor: Colors.red,
    ));
  }
  return result;
}

class _HomeSearchResultScreenState extends State<HomeSearchResultScreen>
    with AutomaticKeepAliveClientMixin<HomeSearchResultScreen> {
  @override
  bool get wantKeepAlive => true;

  String _searchText = '';
  bool isFirstLoading = true;
  bool isLoadingMore = false;
  bool noMoreSnackBarShown = false;

  int currentPage = 1;
  int perPage = 20;
  late int totalPage;

  List<SearchAlbumPaginateItem> albums = [];
  Set<String> albumIds = {};

  late ScrollController _scrollController;

  Future<void> _loadFirst() async {
    if (!isFirstLoading) return;
    final result =
        await getPaginate(context, _searchText, currentPage, perPage);
    if (result == null) return;
    setState(() {
      totalPage = result.totalPages;
      pushAlbums(result.albums);
      isFirstLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore) return;
    if (currentPage >= totalPage) {
      if (noMoreSnackBarShown) return;
      noMoreSnackBarShown = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("これ以上データがありません"),
        backgroundColor: Color.fromARGB(255, 94, 168, 25),
      ));
      return;
    }
    setState(() {
      currentPage++;
      isLoadingMore = true;
    });
    final result =
        await getPaginate(context, _searchText, currentPage, perPage);
    if (result == null) return;
    setState(() {
      pushAlbums(result.albums);
      isLoadingMore = false;
    });
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

  void pushAlbums(List<SearchAlbumPaginateItem> _albums) {
    for (var album in _albums) {
      if (albumIds.contains(album.id)) continue;
      albumIds.add(album.id);
      albums.add(album);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor: CommonColors.primaryThemeDarkColor,
                centerTitle: true,
                // search text input in title
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding:
                        const EdgeInsets.only(left: 40, bottom: 7, right: 10),
                    title: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: CommonColors.secondaryThemeDarkColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: TextFormField(
                          style: TextStyle(
                            color: CommonColors.secondaryTextColor,
                          ),
                          readOnly: true,
                          controller: TextEditingController(text: _searchText),
                          onTap: () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => HomeSearchScreen(
                                      arguments:
                                          HomeSearchArguments(_searchText)),
                                  settings: const RouteSettings(
                                      name: '/home/search/result')),
                            )
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: CommonColors.secondaryThemeDarkColor,
                              hintText:
                                  "曲名・人名・アルバム名", // this will align the text to the exact same height to search.dart
                              suffixIcon: GestureDetector(
                                  onTap: () => {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeSearchScreen(
                                                      arguments:
                                                          HomeSearchArguments(
                                                              '')),
                                              settings: const RouteSettings(
                                                  name: '/home/search/result')),
                                        )
                                      },
                                  child: Icon(Icons.clear,
                                      color: CommonColors.primaryThemeColor))),
                        ),
                      ),
                    )),
                pinned: true,
                shape: Border(
                    bottom: BorderSide(
                        color: CommonColors.secondaryThemeDarkColor, width: 1)),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: CommonColors.primaryThemeColor),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
        body: Container(
          decoration: BoxDecoration(
            color: CommonColors.primaryThemeDarkColor,
          ),
          child: isFirstLoading
              ? const Center(
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator()))
              : albums.isEmpty
                  ? Center(
                      child: Text(
                      "検索結果がありません",
                      style: TextStyle(color: CommonColors.secondaryTextColor),
                    ))
                  : Scrollbar(
                      child: Stack(children: [
                        ListView(
                          padding: const EdgeInsets.only(top: 10),
                          controller: _scrollController,
                          children: [
                            ...albums,
                            if (isLoadingMore)
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50),
                                  child: Center(
                                      child: CircularProgressIndicator()))
                          ],
                        )
                      ]),
                    ),
        ));
  }
}
