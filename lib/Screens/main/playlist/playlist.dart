import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orpheus_client/Screens/main/playlist/show_playlist.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/styles.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen>
    with AutomaticKeepAliveClientMixin<PlaylistScreen> {
  @override
  bool get wantKeepAlive => true;
  List<Playlist> _playlists = [];

  Future<void> _loadPlaylists() async {
    // await DatabaseHelper.setDatabase();
    final pl = await loadPlaylists();

    setState(() {
      _playlists = pl;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "プレイリスト",
        ),
        backgroundColor: CommonColors.primaryThemeDarkColor,
        centerTitle: true,
        titleTextStyle:
            TextStyle(color: CommonColors.secondaryTextColor, fontSize: 20),
        shape: Border(
            bottom: BorderSide(
                color: CommonColors.secondaryThemeDarkColor, width: 1)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
                onPressed: () async {
                  final result = await showTextInputDialog(
                      context: context,
                      textFields: [const DialogTextField(hintText: 'お気に入り')],
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
                icon: Icon(
                  Icons.add_rounded,
                  color: CommonColors.primaryThemeColor,
                )),
          )
        ],
      ),
      body: Container(
        color: CommonColors.primaryThemeDarkColor,
        child: RefreshIndicator(
          onRefresh: _loadPlaylists,
          child: ListView.builder(
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                        builder: (context) => ShowPlaylistScreen(
                              playlistId: playlist.id!,
                              playlistTitle: playlist.title,
                            )),
                  );
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CommonColors.primaryThemeDarkColor),
                    shadowColor: MaterialStateProperty.all<Color>(
                        CommonColors.primaryThemeColor)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.playlist_play_rounded, size: 30),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width * 0.7),
                      child: Text(playlist.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: CommonColors.primaryTextColor,
                              fontSize: 16)),
                    ),
                    const Expanded(
                        child: SizedBox(
                      height: 60,
                    )),
                    IconButton(
                        onPressed: () {
                          openMoreModal(context, playlist, _loadPlaylists);
                        },
                        icon: const Icon(Icons.more_vert_rounded))
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void openMoreModal(
    BuildContext context, Playlist playlist, Future<void> Function() reloader) {
  final size = MediaQuery.of(context).size;
  showModalBottomSheet<void>(
    isScrollControlled: true,
    backgroundColor: CommonColors.secondaryThemeDarkColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          style: TextStyle(
                              color: CommonColors.primaryTextColor,
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${DateFormat("yyyy/MM/dd HH:mm:ss").format(playlist.createdAt.toLocal())} 作成",
                          style:
                              TextStyle(color: CommonColors.secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    color: CommonColors.primaryThemeColor,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(
                color: CommonColors.primaryThemeColor,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CommonColors.secondaryThemeDarkColor),
                    shadowColor:
                        MaterialStateProperty.all<Color>(Colors.transparent)),
                onPressed: () {},
                child: Row(children: const [
                  Icon(Icons.shuffle_rounded),
                  SizedBox(width: 8),
                  Text("シャッフル再生"),
                ]),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CommonColors.secondaryThemeDarkColor),
                    shadowColor:
                        MaterialStateProperty.all<Color>(Colors.transparent)),
                onPressed: () {},
                child: Row(children: const [
                  Icon(Icons.playlist_add_rounded),
                  SizedBox(width: 8),
                  Text("キューに追加"),
                ]),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CommonColors.secondaryThemeDarkColor),
                    shadowColor:
                        MaterialStateProperty.all<Color>(Colors.transparent)),
                onPressed: () async {
                  final result = await showTextInputDialog(
                      isDestructiveAction: true,
                      context: context,
                      textFields: [
                        DialogTextField(
                            initialText: playlist.title, hintText: 'お気に入り')
                      ],
                      title: '名前を変更',
                      message: '新しい名前を入力してください',
                      okLabel: '変更',
                      cancelLabel: 'キャンセル');
                  if (result == null) {
                    return;
                  }
                  final playlistName = result[0];
                  renamePlaylist(playlist.id!, playlistName);
                  await reloader();
                  Navigator.pop(context);
                },
                child: Row(children: const [
                  Icon(Icons.mode_edit_rounded),
                  SizedBox(width: 8),
                  Text("名前を変更"),
                ]),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        CommonColors.secondaryThemeDarkColor),
                    shadowColor:
                        MaterialStateProperty.all<Color>(Colors.transparent)),
                onPressed: () async {
                  final result = await showOkCancelAlertDialog(
                      context: context,
                      title: "プレイリストを削除",
                      message: "プレイリスト「${playlist.title}」を削除しますか？",
                      okLabel: "削除",
                      cancelLabel: "キャンセル",
                      isDestructiveAction: true);
                  if (result == OkCancelResult.cancel) return;
                  await deletePlaylist(playlist.id!);
                  await reloader();
                  Navigator.pop(context);
                },
                child: Row(children: const [
                  Icon(Icons.delete_forever_outlined),
                  SizedBox(width: 8),
                  Text("プレイリストを削除"),
                ]),
              ),
            ],
          ),
        ),
      );
    },
  );
}
