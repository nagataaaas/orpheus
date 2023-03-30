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
    if (currentPage < totalPage) {
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
