import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/home/search.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/api/albums.dart' as albumsApi;
import 'package:orpheus_client/exeptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orpheus_client/components/album_paginate_item.dart';
import 'package:orpheus_client/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

Future<albumsApi.AlbumsGetResponse?> getPaginate(
    BuildContext context, int page, perPage) async {
  late albumsApi.AlbumsGetResponse? result;
  try {
    result = await albumsApi.Albums.get(page: page, perPage: perPage);
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

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  int currentPage = 1;
  int perPage = 20;
  late int totalPage;

  bool isFirstLoading = true;
  bool isLoadingMore = false;

  List<AlbumPaginateItem> albums = [];
  Set<String> albumIds = {};

  late ScrollController _scrollController;

  Future<void> _loadFirst() async {
    if (!isFirstLoading) return;
    final result = await getPaginate(context, currentPage, perPage);
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
      final result = await getPaginate(context, currentPage, perPage);
      if (result == null) return;
      setState(() {
        pushAlbums(result.albums);
        isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    final result = await getPaginate(context, 1, perPage);
    if (result == null) return;
    setState(() {
      insertAlbumsHead(result.albums);
    });
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

  void pushAlbums(List<AlbumPaginateItem> _albums) {
    for (var album in _albums) {
      if (albumIds.contains(album.id)) continue;
      albumIds.add(album.id);
      albums.add(album);
    }
  }

  void insertAlbumsHead(List<AlbumPaginateItem> _albums) {
    for (var album in _albums) {
      if (albumIds.contains(album.id)) continue;
      albumIds.add(album.id);
      albums.insert(0, album);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return Container(
      color: CommonColors.primaryThemeDarkColor,
      child: Scrollbar(
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
                  SliverAppBar(
                    backgroundColor: CommonColors.primaryThemeDarkColor,
                    centerTitle: true,
                    title: Text("新着アルバム",
                        style:
                            TextStyle(color: CommonColors.secondaryTextColor)),
                    pinned: true,
                    shape: Border(
                        bottom: BorderSide(
                            color: CommonColors.secondaryThemeDarkColor,
                            width: 1)),
                    actions: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HomeSearchScreen(),
                                    settings: const RouteSettings(
                                        name: '/home/search')));
                          },
                          icon: Icon(Icons.search_outlined,
                              color: CommonColors.primaryThemeColor))
                    ],
                  )
                ],
            body: isFirstLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10),
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
      ),
    );
  }
}
