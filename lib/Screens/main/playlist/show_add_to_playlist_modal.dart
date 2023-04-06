import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';

class AddToPlaylist extends StatefulWidget {
  final String sourceId;
  final String sourceType;
  const AddToPlaylist(
      {super.key, required this.sourceId, required this.sourceType});

  @override
  State<AddToPlaylist> createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  List<Playlist> _playlists = [];
  List<int> _playlistIdsHasItem = [];

  Future<void> _loadPlaylists() async {
    // await DatabaseHelper.setDatabase();
    final pl = await loadPlaylists();
    final __playlistIdsHasItem =
        await playlistIdsHasItem(widget.sourceId, widget.sourceType);

    setState(() {
      _playlists = pl;
      _playlistIdsHasItem = __playlistIdsHasItem;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
      child: Container(
        decoration: BoxDecoration(
          color: CommonColors.secondaryThemeDarkColor,
          borderRadius: BorderRadius.circular(20),
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text("追加先...",
                      style: TextStyle(
                          color: CommonColors.secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: CommonColors.secondaryThemeDarkColor,
                      shadowColor: CommonColors.secondaryThemeDarkColor,
                    ),
                    onPressed: () async {
                      final result = await showTextInputDialog(
                          context: context,
                          textFields: [
                            const DialogTextField(hintText: 'お気に入り')
                          ],
                          title: 'プレイリストを作成',
                          message: 'プレイリストの名前を入力してください',
                          okLabel: '作成',
                          cancelLabel: 'キャンセル');
                      if (result == null) {
                        return;
                      }
                      final playlistName = result[0];
                      Playlist.createWithTitle(playlistName);
                      await _loadPlaylists();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: CommonColors.linkTextColor,
                        ),
                        Text(
                          "新しいプレイリスト",
                          style: TextStyle(
                              color: CommonColors.linkTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
              ],
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    final alreadyHasItem =
                        _playlistIdsHasItem.contains(playlist.id!);
                    return ElevatedButton(
                      onPressed: () async {
                        if (alreadyHasItem) {
                          await PlaylistTrack.removeFromPlaylist(
                              playlist.id!, widget.sourceId, widget.sourceType);
                        } else {
                          await PlaylistTrack.addToPlaylist(
                              playlist.id!, widget.sourceId, widget.sourceType);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              alreadyHasItem
                                  ? "プレイリストから削除しました"
                                  : "プレイリストに追加しました",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: CommonColors.secondaryThemeDarkColor,
                        shadowColor: CommonColors.secondaryThemeDarkColor,
                      ),
                      child: ListTile(
                        leading: Icon(
                          alreadyHasItem
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: CommonColors.secondaryTextColor,
                        ),
                        title: Text(
                          playlist.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showAddToPlaylistModal(BuildContext context,
    {Album? album, Group? group, Track? track}) {
  late String sourceId;
  late String sourceType;
  if (album != null) {
    sourceId = album.id;
    sourceType = "album";
  } else if (group != null) {
    sourceId = group.id.toString();
    sourceType = "group";
  } else if (track != null) {
    sourceId = track.id.toString();
    sourceType = "track";
  } else {
    throw Exception("target is null");
  }
  final rootContext =
      context.findRootAncestorStateOfType<NavigatorState>()?.context;
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: rootContext ?? context,
    builder: (context) {
      return AddToPlaylist(sourceId: sourceId, sourceType: sourceType);
    },
  );
}
