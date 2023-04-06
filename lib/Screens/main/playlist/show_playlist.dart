import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';
import 'package:orpheus_client/Screens/main/common/album/album_description.dart';
import 'package:orpheus_client/Screens/main/common/album/album_track_list.dart';
import 'package:orpheus_client/Screens/main/common/album/play_button.dart';
import 'package:orpheus_client/Screens/main/common/album/sliver_custom_appbar.dart';
import 'package:orpheus_client/Screens/main/playlist/navigation.dart';
import 'package:orpheus_client/api/albums.dart';
import 'package:orpheus_client/components/auto_marquee.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

const albumItemHeight = 70.0;
const groupItemHeight = 50.0;
const trackItemHeight = 30.0;

class ShowPlaylistArguments {
  int playlistId;
  String playlistTitle;
  ShowPlaylistArguments(
      {required this.playlistId, required this.playlistTitle});
}

class ShowPlaylistScreen extends StatefulWidget {
  final int playlistId;
  final String playlistTitle;
  const ShowPlaylistScreen(
      {super.key, required this.playlistId, required this.playlistTitle});

  @override
  _ShowPlaylistScreenState createState() => _ShowPlaylistScreenState();
}

abstract class ObjectWithPlaylistTracks extends StatelessWidget {
  const ObjectWithPlaylistTracks({super.key});
}

class AlbumWithPlaylistTracks extends ObjectWithPlaylistTracks {
  Album album;
  List<GroupWithPlaylistTracks> groups;
  List<PlaylistTrack> playlistTracks;
  Future<void> Function() onDismissed;
  AlbumWithPlaylistTracks(
      {super.key,
      required this.album,
      required this.groups,
      required this.playlistTracks,
      required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    var fadeInImage = FadeInImage.assetNetwork(
      placeholder: 'assets/no-image.jpg',
      image: album.artworkUrl,
      height: albumItemHeight * 0.9,
    );

    var popUpMenuItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 300,
          child: Text(album.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: CommonColors.primaryDarkTextColor)),
        ),
      ),
      const PopupMenuDivider(),
      // show context header
      PopupMenuItem(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: album.title));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('コピーしました'),
            ),
          );
        },
        value: 'title',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.title_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('タイトルをコピー'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () async {
          await context
              .read<PlayState>()
              .setTracksAsSource((await extractTracks(context))..shuffle());
        },
        value: 'shuffle',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.shuffle_rounded,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('シャッフル再生'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () async {
          await context
              .read<PlayState>()
              .queueTracksAsSource(await extractTracks(context));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'キューに追加しました',
            ),
            duration: const Duration(seconds: 1),
          ));
        },
        value: 'queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_queue_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('キューに追加'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () => Future(() => Navigator.of(context).push(
              CupertinoPageRoute(
                  builder: (context) => CommonAlbumScreen(
                        albumId: album.id,
                        albumTitle: album.title,
                        image: fadeInImage.image,
                      )),
            )),
        value: 'open',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.open_in_new,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('アルバムページを開く'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () {
          for (var element in playlistTracks) {
            PlaylistTrack.removeFromPlaylist(
                element.playlistId, element.sourceId, element.sourceType);
          }
          onDismissed();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "「${album.title}」をプレイリストから削除しました",
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        value: 'remove_from_queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_remove_rounded,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('プレイリストから削除'),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        Dismissible(
            key: ObjectKey(this),
            background: Container(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              for (var element in playlistTracks) {
                PlaylistTrack.removeFromPlaylist(
                    element.playlistId, element.sourceId, element.sourceType);
              }
              onDismissed();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "「${album.title}」をプレイリストから削除しました",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  color: CommonColors.tertiaryThemeDarkColor,
                  height: albumItemHeight,
                  child: ElevatedButton(
                    onLongPress: () async {
                      RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final result = await showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            renderBox.localToGlobal(Offset.zero).dx,
                            renderBox.localToGlobal(Offset.zero).dy,
                            renderBox.localToGlobal(Offset.zero).dx,
                            renderBox.localToGlobal(Offset.zero).dy,
                          ),
                          items: popUpMenuItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      await setAsSource(context);
                    },
                    child: Row(
                      children: [
                        fadeInImage,
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(album.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: CommonColors.primaryTextColor)),
                        ),
                        SizedBox(
                          width: 35,
                          child: GestureDetector(
                              onTapDown: (details) async {
                                final position = details.globalPosition;

                                final result = await showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        position.dx, position.dy, 0, 0),
                                    items: popUpMenuItems);
                              },
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: CommonColors.tertiaryTextColor,
                                size: 25,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
                ...groups,
              ],
            ))
      ],
    );
  }

  Future<void> setAsSource(BuildContext context) async {
    await context
        .read<PlayState>()
        .setTracksAsSource(await extractTracks(context));
  }

  Future<void> queueAsSource(BuildContext context) async {
    await context
        .read<PlayState>()
        .queueTracksAsSource(await extractTracks(context));
  }

  Future<List<Track>> extractTracks(BuildContext context) async {
    if (album.groups.isEmpty) {
      // this group is directly playable
      return await loadAlbum(album.id).then((album) =>
          album.groups.map((g) => g.tracks).expand((media) => media).toList());
    }
    var tracks = <Track>[];
    for (var group in groups) {
      tracks.addAll(await group.extractTracks(context));
    }
    return tracks;
  }
}

class GroupWithPlaylistTracks extends ObjectWithPlaylistTracks {
  Group group;
  List<TrackWithPlaylistTrack> tracks;
  List<PlaylistTrack> playlistTracks;
  Future<void> Function() onDismissed;
  bool isDissmissableAlone = true;
  GroupWithPlaylistTracks(
      {super.key,
      required this.group,
      required this.tracks,
      required this.playlistTracks,
      required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    var popUpMenuItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 300,
          child: Text(group.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: CommonColors.primaryDarkTextColor)),
        ),
      ),
      const PopupMenuDivider(),
      // show context header
      PopupMenuItem(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: group.name));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('コピーしました'),
            ),
          );
        },
        value: 'title',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.title_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('タイトルをコピー'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () async {
          await context
              .read<PlayState>()
              .setTracksAsSource((await extractTracks(context))..shuffle());
        },
        value: 'shuffle',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.shuffle_rounded,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('シャッフル再生'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () async {
          await context
              .read<PlayState>()
              .queueTracksAsSource(await extractTracks(context));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'キューに追加しました',
            ),
            duration: const Duration(seconds: 1),
          ));
        },
        value: 'queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_queue_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('キューに追加'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () {
          for (var element in playlistTracks) {
            PlaylistTrack.removeFromPlaylist(
                element.playlistId, element.sourceId, element.sourceType);
          }
          onDismissed();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "「${group.name}」をプレイリストから削除しました",
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        value: 'remove_from_queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_remove_rounded,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('プレイリストから削除'),
          ],
        ),
      ),
    ];

    var column = Column(
      children: [
        Container(
          height: groupItemHeight,
          color: CommonColors.secondaryThemeDarkColor,
          child: ElevatedButton(
            onLongPress: () async {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              final result = await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    renderBox.localToGlobal(Offset.zero).dx,
                    renderBox.localToGlobal(Offset.zero).dy,
                    renderBox.localToGlobal(Offset.zero).dx,
                    renderBox.localToGlobal(Offset.zero).dy,
                  ),
                  items: popUpMenuItems);
            },
            onPressed: () async {
              await setAsSource(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: Row(
              children: [
                const SizedBox(width: albumItemHeight * 0.3),
                Container(
                    height: groupItemHeight,
                    width: 5,
                    decoration: BoxDecoration(
                      color: CommonColors.secondaryThemeColor,
                    )),
                const SizedBox(width: albumItemHeight * 0.3),
                Expanded(
                  child: Text(group.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 16, color: CommonColors.primaryTextColor)),
                ),
                SizedBox(
                  width: 35,
                  child: GestureDetector(
                      onTapDown: (details) async {
                        final position = details.globalPosition;

                        final result = await showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                                position.dx, position.dy, 0, 0),
                            items: popUpMenuItems);
                      },
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: CommonColors.tertiaryTextColor,
                        size: 25,
                      )),
                )
              ],
            ),
          ),
        ),
        ...tracks,
      ],
    );
    return !isDissmissableAlone
        ? column
        : Column(
            children: [
              Dismissible(
                  key: ObjectKey(this),
                  background: Container(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    for (var element in playlistTracks) {
                      PlaylistTrack.removeFromPlaylist(element.playlistId,
                          element.sourceId, element.sourceType);
                    }
                    onDismissed();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "「${group.name}」をプレイリストから削除しました",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: column)
            ],
          );
  }

  Future<void> setAsSource(BuildContext context) async {
    await context
        .read<PlayState>()
        .setTracksAsSource(await extractTracks(context));
  }

  Future<void> queueAsSource(BuildContext context) async {
    await context
        .read<PlayState>()
        .queueTracksAsSource(await extractTracks(context));
  }

  Future<List<Track>> extractTracks(BuildContext context) async {
    if (tracks.isEmpty) {
      // this group is directly playable
      return (await loadGroup(group.id)).tracks;
    }
    return tracks.map((e) => e.extractTrack()).toList();
  }
}

class TrackWithPlaylistTrack extends ObjectWithPlaylistTracks {
  Track track;
  PlaylistTrack playlistTrack;
  Future<void> Function() onDismissed;
  bool isDissmissableAlone = true;
  TrackWithPlaylistTrack(
      {super.key,
      required this.track,
      required this.playlistTrack,
      required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    var popUpMenuItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 300,
          child: Text(track.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: CommonColors.primaryDarkTextColor)),
        ),
      ),
      const PopupMenuDivider(),
      // show context header
      PopupMenuItem(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: track.title));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('コピーしました'),
            ),
          );
        },
        value: 'title',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.title_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('タイトルをコピー'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () async {
          await context.read<PlayState>().queueTracksAsSource([track]);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'キューに追加しました',
            ),
            duration: const Duration(seconds: 1),
          ));
        },
        value: 'queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_queue_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('キューに追加'),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () {
          PlaylistTrack.removeFromPlaylist(playlistTrack.playlistId,
              playlistTrack.sourceId, playlistTrack.sourceType);
          onDismissed();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "「${track.title}」をプレイリストから削除しました",
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        value: 'remove_from_queue',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_remove_rounded,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('プレイリストから削除'),
          ],
        ),
      ),
    ];

    var button = Container(
      height: trackItemHeight,
      color: CommonColors.secondaryThemeDarkColor,
      child: ElevatedButton(
        onPressed: () async {
          setAsSource(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        child: Row(
          children: [
            const SizedBox(width: albumItemHeight * 0.3),
            Container(
                height: groupItemHeight,
                width: 5,
                decoration: BoxDecoration(
                  color: CommonColors.secondaryThemeColor,
                )),
            const SizedBox(width: albumItemHeight * 0.3),
            const SizedBox(width: groupItemHeight * 0.3),
            Container(
                height: trackItemHeight,
                width: 5,
                decoration: BoxDecoration(
                  color: CommonColors.secondaryThemeColor,
                )),
            const SizedBox(width: groupItemHeight * 0.3),
            Expanded(
              child: Text(track.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 16, color: CommonColors.primaryTextColor)),
            ),
            SizedBox(
              width: 35,
              child: GestureDetector(
                  onTapDown: (details) async {
                    final position = details.globalPosition;

                    final result = await showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            position.dx, position.dy, 0, 0),
                        items: popUpMenuItems);
                  },
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: CommonColors.tertiaryTextColor,
                    size: 25,
                  )),
            )
          ],
        ),
      ),
    );
    return !isDissmissableAlone
        ? button
        : Column(
            children: [
              Dismissible(
                  key: ObjectKey(this),
                  background: Container(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    PlaylistTrack.removeFromPlaylist(playlistTrack.playlistId,
                        playlistTrack.sourceId, playlistTrack.sourceType);
                    onDismissed();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "「${track.title}」をプレイリストから削除しました",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: button)
            ],
          );
  }

  Future<void> setAsSource(BuildContext context) async {
    await context.read<PlayState>().setTracksAsSource([track]);
  }

  Future<void> queueAsSource(BuildContext context) async {
    await context.read<PlayState>().queueTracksAsSource([track]);
  }

  Track extractTrack() {
    return track;
  }
}

Future<List<AlbumWithPlaylistTracks>> buildPlaylistItems(
    List<PlaylistTrack> playlistTracks,
    Future<void> Function() onDismissed) async {
  List<AlbumWithPlaylistTracks> albums = [];
  List<GroupWithPlaylistTracks> groups = [];
  List<TrackWithPlaylistTrack> tracks = [];

  Future<void> raiseGroup() async {
    albums.add(AlbumWithPlaylistTracks(
        onDismissed: onDismissed,
        album: await loadAlbum(groups.first.group.albumId, withGroups: false)
          ..groups = groups.map((e) => e.group).toList(),
        groups: groups,
        playlistTracks:
            groups.map((e) => e.playlistTracks).expand((e) => e).toList()));
    if (albums.last.groups.length == 1) {
      albums.last.groups.first.isDissmissableAlone = false;
    }
    groups = [];
  }

  Future<void> raiseTrack() async {
    final group = GroupWithPlaylistTracks(
        onDismissed: onDismissed,
        group: await loadGroup(tracks.first.track.groupId, withTracks: false)
          ..tracks = tracks.map((e) => e.track).toList(),
        tracks: tracks,
        playlistTracks: tracks.map((e) => e.playlistTrack).toList());
    if (group.tracks.length == 1) {
      group.tracks.first.isDissmissableAlone = false;
    }
    if (groups.isNotEmpty && groups.last.group.albumId != group.group.albumId) {
      await raiseGroup();
    }
    groups.add(group);
    tracks = [];
  }

  for (final playlistTrack in playlistTracks) {
    if (playlistTrack.sourceType != "track" && tracks.isNotEmpty) {
      await raiseTrack();
    }
    if (playlistTrack.sourceType == "album" && groups.isNotEmpty) {
      await raiseGroup();
    }
    if (playlistTrack.sourceType == "album") {
      final album = await loadAlbum(playlistTrack.sourceId, withGroups: false);
      albums.add(AlbumWithPlaylistTracks(
          onDismissed: onDismissed,
          album: album,
          groups: [],
          playlistTracks: [playlistTrack]));
    } else if (playlistTrack.sourceType == "group") {
      final group = GroupWithPlaylistTracks(
          onDismissed: onDismissed,
          group: await loadGroup(int.parse(playlistTrack.sourceId),
              withTracks: false),
          tracks: [],
          playlistTracks: [playlistTrack]);
      if (groups.isNotEmpty &&
          groups.last.group.albumId != group.group.albumId) {
        await raiseGroup();
      }
      groups.add(group);
    } else if (playlistTrack.sourceType == "track") {
      final track = TrackWithPlaylistTrack(
          onDismissed: onDismissed,
          track: await loadTrack(int.parse(playlistTrack.sourceId)),
          playlistTrack: playlistTrack);
      if (tracks.isNotEmpty &&
          tracks.last.track.groupId != track.track.groupId) {
        await raiseTrack();
      }
      tracks.add(track);
    }
  }
  if (tracks.isNotEmpty) {
    await raiseTrack();
  }
  if (groups.isNotEmpty) {
    await raiseGroup();
  }
  return albums;
}

class _ShowPlaylistScreenState extends State<ShowPlaylistScreen> {
  List<PlaylistTrack> _playlistTracks = [];
  List<AlbumWithPlaylistTracks> albums = [];
  List<AlbumWithPlaylistTracks> filteredAlbums = []; // filter with search text
  TextEditingController _searchTextController = TextEditingController();
  Playlist? playlist;
  bool ignorePlay = false;

  Future<void> reloadPlaylist() async {
    final playlistTracks =
        await PlaylistTrack.loadPlaylistTracks(widget.playlistId);
    final _albums =
        await buildPlaylistItems(playlistTracks, this.reloadPlaylist);
    setState(() {
      _playlistTracks = playlistTracks;
      albums = _albums;
      filteredAlbums = filterAlbum(_searchTextController.text, albums);
    });
  }

  @override
  void initState() {
    super.initState();

    Playlist.findById(widget.playlistId).then((value) {
      setState(() {
        playlist = value;
      });
    });

    reloadPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: CommonColors.primaryThemeDarkColor,
      child: NestedScrollView(
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
                      controller: _searchTextController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: CommonColors.secondaryThemeDarkColor,
                          hintText: "プレイリスト内を検索",
                          hintStyle: TextStyle(
                            color: CommonColors.secondaryTextColor,
                          ),
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _searchTextController.clear();
                                filteredAlbums = albums;
                              },
                              child: Icon(Icons.clear,
                                  color: CommonColors.primaryThemeColor))),
                      onChanged: (value) {
                        setState(() {
                          filteredAlbums =
                              filterAlbum(_searchTextController.text, albums);
                        });
                      },
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
        body: SizedBox(
          height: size.height,
          child: RefreshIndicator(
            onRefresh: reloadPlaylist,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Align(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        widget.playlistTitle,
                        style: TextStyle(
                            color: CommonColors.secondaryTextColor,
                            fontSize: 23),
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        playlist == null
                            ? "loading"
                            : DateFormat("yyyy/mm/dd HH:mm:ss 作成")
                                .format(playlist!.createdAt),
                        style: TextStyle(
                            color: CommonColors.secondaryTextColor,
                            fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      CommonColors.primaryThemeColor,
                                  foregroundColor:
                                      CommonColors.primaryThemeDarkColor),
                              onPressed: () async {
                                if (ignorePlay) return;
                                ignorePlay = true;
                                final List<Track> tracks = [];
                                for (final album in albums) {
                                  tracks.addAll(
                                      await album.extractTracks(context));
                                }
                                await context
                                    .read<PlayState>()
                                    .setTracksAsSource(tracks);
                                context.read<PlayState>().audioPlayer.play();
                                ignorePlay = false;
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: CommonColors.primaryThemeDarkColor,
                                    size: 25,
                                  ),
                                  SizedBox(width: 5),
                                  Text("初めから再生",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: CommonColors
                                              .primaryThemeDarkColor))
                                ],
                              )),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      CommonColors.secondaryThemeDarkColor),
                              onPressed: () async {
                                if (ignorePlay) return;
                                ignorePlay = true;
                                final List<Track> tracks = [];
                                for (final album in albums) {
                                  tracks.addAll(
                                      await album.extractTracks(context));
                                }
                                tracks.shuffle();
                                await context
                                    .read<PlayState>()
                                    .setTracksAsSource(tracks);
                                context.read<PlayState>().audioPlayer.play();
                                ignorePlay = false;
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.shuffle_rounded,
                                      color: CommonColors.primaryThemeColor,
                                      size: 25),
                                  SizedBox(width: 5),
                                  Text("シャッフル再生",
                                      style: TextStyle(fontSize: 14))
                                ],
                              ))
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                ...filteredAlbums
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String hiraToKana(String str) {
  return str.replaceAllMapped(RegExp("[ぁ-ゔ]"),
      (Match m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60));
}

const _fullLengthCode = 65248;
String alphanumericToHalfLength(String str) {
  final regex = RegExp(r'^[Ａ-Ｚａ-ｚ０-９]+$');
  final string = str.runes.map<String>((rune) {
    final char = String.fromCharCode(rune);
    return regex.hasMatch(char)
        ? String.fromCharCode(rune - _fullLengthCode)
        : char;
  });
  return string.join();
}

List<AlbumWithPlaylistTracks> filterAlbum(
    String searchText, List<AlbumWithPlaylistTracks> albums) {
  List<AlbumWithPlaylistTracks> filteredAlbums = [];
  if (searchText.trim().isEmpty) {
    return albums;
  }

  List<String> queries =
      alphanumericToHalfLength(hiraToKana(searchText.toLowerCase()))
          .split(RegExp(r"\s+"));
  bool containsQuery(List<String> queries, String text) {
    final convertedText =
        alphanumericToHalfLength(hiraToKana(text.toLowerCase()));
    for (var query in queries) {
      if (convertedText.contains(query)) {
        return true;
      }
    }
    return false;
  }

  for (var album in albums) {
    if (containsQuery(queries, album.album.title) ||
        containsQuery(queries, album.album.originalTitle) ||
        containsQuery(queries, album.album.category ?? '') ||
        containsQuery(
            queries,
            jsonDecode(album.album.contributors ?? '{value: [{"name": ""}]}')[
                    'value']
                .map((e) => e['name'])
                .join('')) ||
        containsQuery(queries, album.album.label ?? '')) {
      filteredAlbums.add(album);
      continue;
    }
    if (album.groups.isEmpty) {
      continue;
    }
    List<GroupWithPlaylistTracks> filteredGroups = [];
    for (var group in album.groups) {
      if (containsQuery(queries, group.group.albumTitle) ||
          containsQuery(queries, group.group.name) ||
          containsQuery(queries, group.group.originalName) ||
          containsQuery(
              queries,
              jsonDecode(group.group.contributors)['value']
                  .map((e) => e['name'])
                  .join(''))) {
        filteredGroups.add(group);
        continue;
      }
      if (group.tracks.isEmpty) {
        continue;
      }

      List<TrackWithPlaylistTrack> filteredTracks = [];
      for (var track in group.tracks) {
        if (containsQuery(queries, track.track.albumTitle) ||
            containsQuery(queries, track.track.groupName) ||
            containsQuery(queries, track.track.genre) ||
            containsQuery(queries, track.track.title) ||
            containsQuery(queries, track.track.originalTitle) ||
            containsQuery(
                queries,
                jsonDecode(track.track.contributors)['value']
                    .map((e) => e['name'])
                    .join(''))) {
          filteredTracks.add(track);
        }
      }
      if (filteredTracks.isNotEmpty) {
        filteredGroups.add(GroupWithPlaylistTracks(
            onDismissed: group.onDismissed,
            group: group.group,
            tracks: filteredTracks,
            playlistTracks: group.playlistTracks));
      }
    }
    if (filteredGroups.isNotEmpty) {
      filteredAlbums.add(AlbumWithPlaylistTracks(
          onDismissed: album.onDismissed,
          album: album.album,
          groups: filteredGroups,
          playlistTracks: album.playlistTracks));
    }
  }
  return filteredAlbums;
}
