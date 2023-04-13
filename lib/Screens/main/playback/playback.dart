import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'resolving_audio_source.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:orpheus_client/my_flutter_app_icons.dart';

class PlayBackScreen extends StatefulWidget {
  const PlayBackScreen({Key? key}) : super(key: key);

  @override
  _PlayBackScreenState createState() => _PlayBackScreenState();
}

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  const Controls({super.key, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    final processingState = context.watch<PlayState>().processingState;
    final playing = context.watch<PlayState>().isPlaying;
    final currentIndex = context.watch<PlayState>().audioPlayer.currentIndex;
    final currentTrackId = context.watch<PlayState>().currentTrackId;
    final hasNextTrack = context.watch<PlayState>().hasNextTrack;
    final hasPreviousTrack = context.watch<PlayState>().hasPreviousTrack;
    final color = currentTrackId == null
        ? CommonColors.primaryThemeColor.withOpacity(0.5)
        : CommonColors.primaryThemeColor;
    late final playPauseButton;
    const iconSize = 32.0;
    final isTrackSelected = !(currentIndex == null ||
        currentTrackId == null ||
        context.read<PlayState>().playlist.length <= currentIndex);

    if ((playing != false) && (processingState != ProcessingState.completed)) {
      // playing
      playPauseButton = IconButton(
          onPressed: () async {
            await context.read<PlayState>().audioPlayer.pause();
          },
          iconSize: iconSize * 2,
          color: color,
          icon: const Icon(Icons.pause_circle_filled_rounded));
    } else if (processingState != ProcessingState.completed) {
      // paused
      playPauseButton = IconButton(
          onPressed: () async {
            context.read<PlayState>().audioPlayer.play();
          },
          iconSize: iconSize * 2,
          color: color,
          icon: const Icon(Icons.play_circle_fill_rounded));
    } else {
      // end of music
      playPauseButton = IconButton(
        onPressed: () async {
          await context.read<PlayState>().playFirstTrack();
        },
        iconSize: iconSize * 2,
        color: color,
        icon: const Icon(
          Icons.play_circle_fill_rounded,
        ),
      );
    }

    final previousButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        if (hasPreviousTrack) {
          await context.read<PlayState>().audioPlayer.seekToPrevious();
        }
      },
      iconSize: iconSize,
      color: hasPreviousTrack
          ? color
          : CommonColors.primaryThemeColor.withOpacity(0.5),
      icon: const Icon(Icons.skip_previous_rounded),
    );

    final nextButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        if (hasNextTrack) {
          await context.read<PlayState>().audioPlayer.seekToNext();
        }
      },
      iconSize: iconSize,
      color: hasNextTrack
          ? color
          : CommonColors.primaryThemeColor.withOpacity(0.5),
      icon: const Icon(Icons.skip_next_rounded),
    );

    final replay10 = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        final audioPlayer = context.read<PlayState>().audioPlayer;
        if (isTrackSelected) {
          await audioPlayer.seek(
              Duration(seconds: max(0, audioPlayer.position.inSeconds - 10)));
        }
      },
      iconSize: iconSize,
      color: isTrackSelected
          ? color
          : CommonColors.primaryThemeColor.withOpacity(0.5),
      icon: const Icon(Icons.replay_10_rounded),
    );

    final forward30 = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        final audioPlayer = context.read<PlayState>().audioPlayer;
        if (isTrackSelected) {
          await audioPlayer
              .seek(Duration(seconds: audioPlayer.position.inSeconds + 30));
        }
      },
      iconSize: iconSize,
      color: isTrackSelected
          ? color
          : CommonColors.primaryThemeColor.withOpacity(0.5),
      icon: const Icon(Icons.forward_30_rounded),
    );

    final speed = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        await context
            .read<PlayState>()
            .setSpeed(3 - context.read<PlayState>().speed);
      },
      iconSize: iconSize * 0.8,
      color: color,
      icon: context.read<PlayState>().speed == 1
          ? const Icon(CustomIcon.rabbit)
          : const Icon(CustomIcon.turtle),
    );

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(
          width: iconSize * 0.8,
        ),
        previousButton,
        replay10,
        playPauseButton,
        forward30,
        nextButton,
        speed,
      ],
    );
    if (currentTrackId == null) {
      return IgnorePointer(child: controls);
    }
    return controls;
  }
}

class AlbumInfo extends StatelessWidget {
  const AlbumInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayState>().audioPlayer;
    final currentIndex = player.currentIndex;
    final audioSource = player.audioSource as ConcatenatingAudioSource;
    ImageProvider image;
    String title;
    String albumTitle;
    String artist;
    String albumId;
    if (currentIndex == null || currentIndex >= audioSource.length) {
      image = const AssetImage('assets/no-image.jpg');
      title = 'No track selected';
      albumTitle = '';
      artist = '';
      albumId = '';
    } else {
      final tag =
          (audioSource[currentIndex] as ResolvingAudioSource).tag as MediaItem;
      image = NetworkImage(tag.artUri.toString());
      title = tag.title;
      albumTitle = tag.album!;
      artist = tag.artist!;
      albumId = tag.extras!['albumId'];
    }

    final Size size = MediaQuery.of(context).size;
    final imageSize = min(size.width * 0.7, size.height * 0.5);
    final placeholderImage = Image.asset('assets/no-image.jpg',
        width: imageSize, height: imageSize, fit: BoxFit.cover);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
      onPressed: () {
        if (albumId.isEmpty) return;
        Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) => CommonAlbumScreen(
                    albumId: albumId,
                    albumTitle: title,
                    image: image,
                  )),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: FadeInImage(
                image: image,
                placeholder: placeholderImage.image,
                fadeInDuration: const Duration(milliseconds: 1),
                fadeOutDuration: const Duration(milliseconds: 1),
                imageErrorBuilder: (context, error, stackTrace) =>
                    placeholderImage,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover),
          ),
          SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  albumTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: CommonColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CommonColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: CommonColors.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  PositionData(this.position, this.bufferedPosition, this.duration);
}

class PlayQueue extends StatelessWidget {
  const PlayQueue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.read<PlayState>().audioPlayer.currentIndex;
    final currentTrackId = context.watch<PlayState>().currentTrackId;
    final playlist = context.watch<PlayState>().playlist;
    final loopMode = context.watch<PlayState>().loopMode;
    final isShuffling = context.watch<PlayState>().isShuffling;
    const iconSize = 32.0;
    final color = currentTrackId == null
        ? CommonColors.primaryThemeColor.withOpacity(0.5)
        : CommonColors.primaryThemeColor;

    final shuffleButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () => context.read<PlayState>().setShuffle(!isShuffling),
      iconSize: iconSize,
      color: color,
      icon: isShuffling
          ? const Icon(Icons.shuffle_on_rounded)
          : const Icon(Icons.shuffle_rounded),
    );
    final loopButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () {
        switch (loopMode) {
          case LoopMode.off:
            context.read<PlayState>().setLoopMode(LoopMode.all);
            break;
          case LoopMode.all:
            context.read<PlayState>().setLoopMode(LoopMode.one);
            break;
          case LoopMode.one:
            context.read<PlayState>().setLoopMode(LoopMode.off);
            break;
        }
      },
      iconSize: iconSize,
      color: color,
      icon: {
        LoopMode.off: const Icon(Icons.repeat_rounded),
        LoopMode.one: const Icon(Icons.repeat_one_on_rounded),
        LoopMode.all: const Icon(Icons.repeat_on_rounded),
      }[loopMode]!,
    );

    return Container(
      color: CommonColors.secondaryThemeDarkColor,
      child: Scrollbar(
        thumbVisibility: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  loopButton,
                  const SizedBox(
                    width: 20,
                  ),
                  shuffleButton,
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  final tag = (playlist[index] as ResolvingAudioSource).tag
                      as MediaItem;
                  return Dismissible(
                    key: ObjectKey(tag),
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
                    child: ListTile(
                      title: Text(tag.title,
                          style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                              overflow: TextOverflow.ellipsis)),
                      subtitle: Text(tag.artist!,
                          style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                              overflow: TextOverflow.ellipsis)),
                      leading: Text('${index + 1}',
                          style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                              overflow: TextOverflow.ellipsis)),
                      trailing: index == currentIndex
                          ? Icon(
                              Icons.play_arrow_rounded,
                              color: CommonColors.playButtonColor,
                            )
                          : null,
                      onTap: () async {
                        await context.read<PlayState>().playIndexItem(index);
                      },
                    ),
                    onDismissed: (direction) async {
                      await context
                          .read<PlayState>()
                          .removeTrackFromPlaylist(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayBackScreenState extends State<PlayBackScreen>
    with AutomaticKeepAliveClientMixin<PlayBackScreen> {
  @override
  bool get wantKeepAlive => true;

  bool isPlaying = false;
  int? currentTrackId;
  bool resettingHeader = false;
  late ConcatenatingAudioSource playlist;

  Stream<PositionData> get _positionDataStream {
    final audioPlayer = context.read<PlayState>().audioPlayer;
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final audioPlayer = context.read<PlayState>().audioPlayer;
    final currentTrackId = context.watch<PlayState>().currentTrackId;

    return Container(
      decoration: BoxDecoration(color: CommonColors.primaryThemeDarkColor),
      child: SafeArea(
        child: SnappingSheet(
          grabbingHeight: 75,
          grabbing: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 2,
                      color: CommonColors.secondaryThemeDarkColor,
                      offset: const Offset(0, 10),
                    )
                  ],
                  color: CommonColors.secondaryThemeDarkColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Stack(
                      children: [
                        Text(
                          "再生キュー",
                          style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    Container()
                  ],
                ),
              )),
          sheetBelow:
              SnappingSheetContent(child: const PlayQueue(), draggable: true),
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AlbumInfo(),
                StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      final progressBar = ProgressBar(
                          barHeight: 6,
                          baseBarColor: CommonColors.primaryThemeColor,
                          bufferedBarColor: CommonColors.secondaryThemeColor,
                          thumbColor: Colors.red,
                          progressBarColor: Colors.red,
                          thumbRadius: 8,
                          progress: positionData?.position ?? Duration.zero,
                          timeLabelTextStyle:
                              TextStyle(color: CommonColors.primaryThemeColor),
                          buffered:
                              positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ?? Duration.zero,
                          onSeek: audioPlayer.seek);
                      return audioPlayer.audioSource == null ||
                              currentTrackId == null
                          ? Opacity(
                              opacity: 0.5,
                              child: IgnorePointer(child: progressBar))
                          : progressBar;
                    }),
                Controls(audioPlayer: audioPlayer),
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
