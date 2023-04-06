import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/Screens/main/playlist/show_add_to_playlist_modal.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({
    Key? key,
    required this.scrollController,
    required this.maxAppBarHeight,
    required this.minAppBarHeight,
    required this.playPauseButtonSize,
    required this.infoBoxHeight,
    required this.album,
  }) : super(key: key);

  final ScrollController scrollController;
  final double maxAppBarHeight;
  final double minAppBarHeight;
  final double playPauseButtonSize;
  final double infoBoxHeight;
  final Album album;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(() {
      setState(() {});
    });
  }

  double get getPositionFromTop {
    double position = widget.maxAppBarHeight;
    double finalPosition =
        widget.minAppBarHeight - widget.playPauseButtonSize / 2;

    if (widget.scrollController.hasClients) {
      try {
        double offset = widget.scrollController.offset;
        //When adjusting position, add/subtract in addOrSubtractValue
        double addOrSubtractValue =
            widget.infoBoxHeight - widget.playPauseButtonSize - 10;
        final bool isFinalPosition =
            offset > (position - finalPosition + addOrSubtractValue);
        if (!isFinalPosition) {
          position = position - offset + addOrSubtractValue;
        } else {
          position = finalPosition;
        }
      } catch (e) {
        // at very beginning, widget.scrollController.offset may be fail
        return 0;
      }
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: getPositionFromTop,
      right: 10,
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: CommonColors.playButtonColor,
          fixedSize:
              Size(widget.playPauseButtonSize, widget.playPauseButtonSize),
          shape: const CircleBorder(),
        ),
        onPressed: () async {
          final List<Track> tracks = [];
          for (final group in widget.album.groups) {
            tracks.addAll(group.tracks);
          }
          await context.read<PlayState>().setTracksAsSource(tracks);
        },
        onLongPress: () async {
          // get self offset
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          final result = await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                renderBox.localToGlobal(Offset.zero).dx,
                renderBox.localToGlobal(Offset.zero).dy,
                renderBox.localToGlobal(Offset.zero).dx,
                renderBox.localToGlobal(Offset.zero).dy,
              ),
              items: <PopupMenuEntry<String>>[
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 300,
                    child: Text(widget.album.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: CommonColors.primaryDarkTextColor)),
                  ),
                ),
                const PopupMenuDivider(),
                // show context header
                PopupMenuItem(
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.album.title));
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
                    final List<Track> tracks = [];
                    for (final group in widget.album.groups) {
                      tracks.addAll(group.tracks);
                    }
                    await context.read<PlayState>().queueTracksAsSource(tracks);

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
                    showAddToPlaylistModal(context, album: widget.album);
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
              ]);
        },
        child: const Icon(
          Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}
