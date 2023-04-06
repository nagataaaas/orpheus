import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/styles.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'resolving_audio_source.dart';

class BottomPlayBackBar extends StatefulWidget {
  final void Function() onTap;
  const BottomPlayBackBar({Key? key, required this.onTap}) : super(key: key);

  @override
  _BottomPlayBackBarState createState() => _BottomPlayBackBarState();
}

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    final barHeight = AppBar().preferredSize.height;
    final iconSize = barHeight * 0.85;
    final processingState = context.watch<PlayState>().processingState;
    final hasNextTrack = context.watch<PlayState>().hasNextTrack;
    final playing = context.watch<PlayState>().isPlaying;
    late final IconButton playPauseButton;
    final color = CommonColors.primaryThemeColor;

    if ((playing != false) && (processingState != ProcessingState.completed)) {
      // playing
      playPauseButton = IconButton(
          onPressed: () async {
            await context.read<PlayState>().audioPlayer.pause();
          },
          iconSize: iconSize,
          color: color,
          icon: const Icon(Icons.pause_rounded));
    } else if (processingState != ProcessingState.completed) {
      // not playing
      playPauseButton = IconButton(
          onPressed: () async {
            context.read<PlayState>().audioPlayer.play();
          },
          iconSize: iconSize,
          color: color,
          icon: const Icon(Icons.play_arrow_rounded));
    } else {
      // end of music
      playPauseButton = IconButton(
        onPressed: () async {
          await context.read<PlayState>().playFirstTrack();
        },
        iconSize: iconSize,
        color: color,
        icon: const Icon(
          Icons.play_arrow_rounded,
        ),
      );
    }

    final nextButton = IconButton(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        playPauseButton,
        nextButton,
      ],
    );
  }
}

class DrawInfo extends StatelessWidget {
  final MediaItem tag;
  const DrawInfo({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag.title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CommonColors.secondaryTextColor,
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            tag.artist!,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: CommonColors.secondaryTextColor,
                overflow: TextOverflow.ellipsis),
          )
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

class _BottomPlayBackBarState extends State<BottomPlayBackBar>
    with AutomaticKeepAliveClientMixin<BottomPlayBackBar> {
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

    final currentTrackId = context.watch<PlayState>().currentTrackId;
    final currentIndex = context.watch<PlayState>().audioPlayer.currentIndex;
    if (currentIndex == null ||
        currentTrackId == null ||
        context.read<PlayState>().playlist.length <= currentIndex) {
      return Container();
    }

    final barHeight = AppBar().preferredSize.height;
    final currentPlayingTrack = context
        .watch<PlayState>()
        .playlist[currentIndex] as ResolvingAudioSource;
    final Uri artworkUrl = currentPlayingTrack.tag.artUri;
    final imageSize = barHeight * 0.85;
    final placeholderImage = Image.asset('assets/no-image.jpg',
        width: imageSize, height: imageSize, fit: BoxFit.cover);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: CommonColors.primaryThemeDarkColor),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: widget.onTap,
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: barHeight - imageSize),
                    child: FadeInImage(
                        image: NetworkImage(artworkUrl.toString()),
                        placeholder: placeholderImage.image,
                        fadeInDuration: const Duration(milliseconds: 1),
                        fadeOutDuration: const Duration(milliseconds: 1),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            placeholderImage,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: DrawInfo(tag: currentPlayingTrack.tag as MediaItem),
                  ),
                  const Controls(),
                ],
              ),
            ),
            StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return IgnorePointer(
                    child: ProgressBar(
                        barHeight: 1,
                        baseBarColor: CommonColors.primaryThemeColor,
                        bufferedBarColor: CommonColors.secondaryThemeColor,
                        thumbRadius: 0,
                        progressBarColor: Colors.red,
                        progress: positionData?.position ?? Duration.zero,
                        timeLabelTextStyle: const TextStyle(
                            color: Colors.transparent, fontSize: 0),
                        buffered:
                            positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
