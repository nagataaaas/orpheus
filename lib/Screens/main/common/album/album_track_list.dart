import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/playlist/show_add_to_playlist_modal.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';
import 'package:orpheus_client/components/auto_marquee.dart';

class AlbumTrackList extends StatelessWidget {
  final Album album;
  AlbumTrackList({super.key, required this.album});
  late Offset _tapPosition;

  void _getTapPosision(BuildContext context, TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  String getTrackDuration(int duration) {
    final int hours = (duration / 3600).floor();
    final int minutes = ((duration % 3600) / 60).floor();
    final int seconds = duration % 60;
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget buildTrack(BuildContext context, Track track) {
    double maxWidth = MediaQuery.of(context).size.width - 110 - 25;
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
          showAddToPlaylistModal(context, track: track);
        },
        value: 'playlist',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add_check_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('プレイリストに追加'),
          ],
        ),
      ),
    ];

    return SizedBox(
      height: 40,
      child: InkWell(
        onTapDown: (details) {
          _getTapPosision(context, details);
        },
        onTap: () async {
          await context.read<PlayState>().setTracksAsSource([track]);
        },
        onLongPress: () async {
          final RenderObject? overlay =
              Overlay.of(context)?.context.findRenderObject();

          final result = await showMenu(
              context: context,
              position: RelativeRect.fromRect(
                  Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
                  Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                      overlay.paintBounds.size.height)),
              items: popUpMenuItems);
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.watch<PlayState>().currentTrackId == track.id
                ? CommonColors.playingTrackBackground
                : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildAutoMarquee(track.title, maxWidth),
                const Spacer(),
                Text(
                  getTrackDuration(track.duration),
                  style: TextStyle(
                      color: CommonColors.tertiaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
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
      ),
    );
  }

  Widget buildGroup(BuildContext context, Group group) {
    double maxWidth = MediaQuery.of(context).size.width - 90 - 25;

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
          await context.read<PlayState>().queueTracksAsSource(group.tracks);
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
          showAddToPlaylistModal(context, group: group);
        },
        value: 'playlist',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add_check_outlined,
              color: CommonColors.primaryThemeDarkColor,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('プレイリストに追加'),
          ],
        ),
      ),
    ];
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTapDown: (details) {
            _getTapPosision(context, details);
          },
          onTap: () async {
            await context.read<PlayState>().setTracksAsSource(group.tracks);
          },
          onLongPress: () async {
            final RenderObject? overlay =
                Overlay.of(context).context.findRenderObject();

            final result = await showMenu(
                context: context,
                position: RelativeRect.fromRect(
                    Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
                    Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                        overlay.paintBounds.size.height)),
                items: popUpMenuItems);
          },
          child: Container(
            decoration: BoxDecoration(
              color: (group.actAsTrack &&
                      context.watch<PlayState>().currentTrackId ==
                          group.tracks.first.id)
                  ? CommonColors.playingTrackBackground
                  : Colors.white.withAlpha(25),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildAutoMarquee(group.name, maxWidth),
                    const Spacer(),
                    Text(
                      getTrackDuration(group.duration),
                      style: TextStyle(
                          color: CommonColors.tertiaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
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
          ),
        ),
        if (!group.actAsTrack)
          ...group.tracks.map((track) => buildTrack(context, track)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            decoration:
                BoxDecoration(color: CommonColors.primaryThemeDarkColor),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ...album.groups
                    .map((group) => buildGroup(context, group))
                    .toList(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
