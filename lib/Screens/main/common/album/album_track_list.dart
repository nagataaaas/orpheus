import 'dart:math';

import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/common/album/album_description.dart';
import 'package:orpheus_client/Screens/main/common/album/play_button.dart';
import 'package:orpheus_client/Screens/main/common/album/sliver_custom_appbar.dart';
import 'package:orpheus_client/api/albums.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/storage/search_history.dart';
import 'package:orpheus_client/Screens/main/home/search_result.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';

class CommonAlbumScreen extends StatefulWidget {
  final String albumId;
  final String albumTitle;
  final NetworkImage? image;
  const CommonAlbumScreen(
      {super.key,
      required this.albumId,
      required this.albumTitle,
      required this.image});

  @override
  _CommonAlbumScreenState createState() => _CommonAlbumScreenState();
}

double calcImageSize(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  const imageRatio = 0.7;
  return size.width * imageRatio;
}

class _CommonAlbumScreenState extends State<CommonAlbumScreen> {
  bool isLoaded = false;

  late ScrollController _scrollController;
  late String albumId;
  late String albumTitle;
  NetworkImage? networkImage;
  Album? album;
  late double maxAppBarHeight;
  late double minAppBarHeight;
  late double playPauseButtonSize;
  late double infoBoxHeight;

  late TextEditingController _searchTextController;

  @override
  void initState() {
    super.initState();
    albumId = widget.albumId;
    albumTitle = widget.albumTitle;
    networkImage = widget.image;
    _scrollController = ScrollController();

    Albums.show(albumId).then((value) {
      setState(() {
        album = value;
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final imageSize = calcImageSize(context);
    maxAppBarHeight = MediaQuery.of(context).size.height * 0.5;
    minAppBarHeight = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).size.height * 0.1;
    playPauseButtonSize = (MediaQuery.of(context).size.width / 320) * 50 > 80
        ? 80
        : (MediaQuery.of(context).size.width / 320) * 50;
    infoBoxHeight = 180;

    final image = (!isLoaded)
        ? (networkImage != null
            ? Image(
                image: networkImage!,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover)
            : Image.asset('assets/no-image.jpg',
                width: imageSize, height: imageSize, fit: BoxFit.cover))
        : FadeInImage(
            image: NetworkImage(album!.artworkUrl.toString()),
            placeholder: networkImage!,
            fadeInDuration: const Duration(milliseconds: 1),
            fadeOutDuration: const Duration(milliseconds: 1),
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/no-image.jpg',
                  width: imageSize, height: imageSize, fit: BoxFit.cover);
            },
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover);

    return !isLoaded
        ? Center(
            child: SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(),
          ))
        : DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CommonColors.primaryThemeAccentColor,
                    Colors.black,
                  ],
                  stops: const [
                    0,
                    0.7
                  ]),
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverCustomeAppBar(
                      albumTitle: albumTitle,
                      albumImage: image,
                      maxAppBarHeight: maxAppBarHeight,
                      minAppBarHeight: minAppBarHeight,
                    ),
                    AlbumDescription(
                      title: albumTitle,
                      label: album?.label,
                      onTapAction: () async {
                        print("tapped");
                      },
                    ),
                    SliverFixedExtentList(
                      itemExtent: 200.0,
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Container(
                            alignment: Alignment.center,
                            color: Color.fromARGB(255, 0, 0, 0),
                            child: Text(
                              'list item $index',
                              style: TextStyle(fontSize: 30),
                            ),
                          );
                        },
                      ),
                    ),
                    // AlbumSongList
                  ],
                ),
                PlayButton(
                  scrollController: _scrollController,
                  maxAppBarHeight: maxAppBarHeight,
                  minAppBarHeight: minAppBarHeight,
                  playPauseButtonSize: playPauseButtonSize,
                  infoBoxHeight: infoBoxHeight,
                ),
              ],
            ),
          );
  }
}
