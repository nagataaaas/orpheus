import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/common/album/album_description.dart';
import 'package:orpheus_client/Screens/main/common/album/album_track_list.dart';
import 'package:orpheus_client/Screens/main/common/album/play_button.dart';
import 'package:orpheus_client/Screens/main/common/album/sliver_custom_appbar.dart';
import 'package:orpheus_client/Screens/main/playlist/show_add_to_playlist_modal.dart';
import 'package:orpheus_client/api/albums.dart';
import 'package:orpheus_client/components/auto_marquee.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class CommonAlbumArguments {
  String albumId;
  String albumTitle;
  ImageProvider image;
  CommonAlbumArguments(
      {required this.albumId, required this.albumTitle, required this.image});
}

class CommonAlbumScreen extends StatefulWidget {
  final String albumId;
  final String albumTitle;
  final ImageProvider? image;
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
  ImageProvider? networkImage;
  Album? album;
  late double maxAppBarHeight;
  late double minAppBarHeight;
  late double playPauseButtonSize;
  late double infoBoxHeight;

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
    final imageSize = calcImageSize(context);
    maxAppBarHeight = MediaQuery.of(context).size.height * 0.5;
    minAppBarHeight =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
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
        ? Container(
            color: CommonColors.primaryThemeDarkColor,
            child: const Center(
                child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            )),
          )
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
                      onTapAction: () {
                        showDescriptionModal(context, album!);
                      },
                    ),
                    AlbumDescription(
                      title: albumTitle,
                      label: album?.label,
                      showDescription: () {
                        showDescriptionModal(context, album!);
                      },
                      addToPlaylist: () {
                        showAddToPlaylistModal(context, album: album);
                      },
                      addToQueue: () async {
                        var tracks = <Track>[];
                        for (var group in album!.groups) {
                          tracks.addAll(group.tracks);
                        }
                        await context
                            .read<PlayState>()
                            .queueTracksAsSource(tracks);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'キューに追加しました',
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      playShuffle: () async {
                        var tracks = <Track>[];
                        for (var group in album!.groups) {
                          tracks.addAll(group.tracks);
                        }
                        tracks.shuffle();
                        await context
                            .read<PlayState>()
                            .setTracksAsSource(tracks);
                        await context.read<PlayState>().setShuffle(true);
                        context.read<PlayState>().audioPlayer.play();
                      },
                    ),
                    AlbumTrackList(album: album!)
                  ],
                ),
                PlayButton(
                  scrollController: _scrollController,
                  maxAppBarHeight: maxAppBarHeight,
                  minAppBarHeight: minAppBarHeight,
                  playPauseButtonSize: playPauseButtonSize,
                  infoBoxHeight: infoBoxHeight,
                  album: album!,
                ),
              ],
            ),
          );
  }
}

void showDescriptionModal(BuildContext context, Album album) {
  final size = MediaQuery.of(context).size;
  final descriptionValueWidth = size.width * 0.5;

  showModalBottomSheet<void>(
    backgroundColor: CommonColors.secondaryThemeDarkColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (BuildContext context) {
      final label = (album.label?.isNotEmpty == true)
          ? jsonDecode(album.label!)['description'] ?? '不明'
          : '不明';

      final List<Map<String, dynamic>> contributors = [];
      for (final group in album.groups) {
        for (final track in group.tracks) {
          contributors.addAll(jsonDecode(track.contributors)['value']
              .cast<Map<String, dynamic>>());
        }
      }
      final Map<String, Set<String>> contributorsByTypeMap = {};
      for (final contributor in contributors) {
        final type = contributor['type'];
        final name = contributor['name'];
        if (contributorsByTypeMap[type] == null) {
          contributorsByTypeMap[type] = {name};
        } else {
          contributorsByTypeMap[type]!.add(name);
        }
      }
      return FractionallySizedBox(
        widthFactor: 0.9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                    color: CommonColors.primaryThemeColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // close button on right top
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                icon: const Icon(Icons.close),
                color: CommonColors.primaryThemeColor,
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // body
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: CommonColors.secondaryTextColor,
                  fontSize: 16,
                ),
                child: SizedBox(
                  width: size.width,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: ListView(
                        children: [
                          buildListDesciptionItem(context, 'カタログ番号', {album.id},
                              descriptionValueWidth),
                          buildListDesciptionItem(context, 'アルバム名',
                              {album.title}, descriptionValueWidth),
                          buildListDesciptionItem(context, '元アルバム名',
                              {album.originalTitle}, descriptionValueWidth),
                          buildListDesciptionItem(context, 'ジャンル',
                              {album.category ?? '不明'}, descriptionValueWidth),
                          buildListDesciptionItem(
                              context, 'レーベル', {label}, descriptionValueWidth),
                          ...contributorsByTypeMap.entries.map((e) =>
                              buildListDesciptionItem(context, e.key, e.value,
                                  descriptionValueWidth)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Row buildListDesciptionItem(
    BuildContext context, String title, Set<String> values, double valueWidth) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: values.join(',')));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('コピーしました'),
            ),
          );
        },
        child: Text(title),
      ),
      Column(
          children: values
              .map(
                (e) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: e));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('コピーしました'),
                      ),
                    );
                  },
                  child: buildAutoMarquee(e, valueWidth),
                ),
              )
              .toList())
    ],
  );
}
