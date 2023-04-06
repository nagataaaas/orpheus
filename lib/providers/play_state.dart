import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:orpheus_client/Screens/main/playback/resolving_audio_source.dart';
import 'package:orpheus_client/storage/sqlite.dart';
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import 'package:orpheus_client/api/common.dart'
    show generateAuthHeader, apiPrefix;

Future<Map<String, String>> Function() createHeader(Uri url) {
  return (() async {
    final accessKey = await credentials.AccessKey.get();
    final secretKey = await credentials.SecretKey.get();
    return generateAuthHeader(accessKey, secretKey, 'GET', url.toString());
  });
}

Uri resourceToUrl(String resource) {
  return Uri.parse(apiPrefix + resource);
}

ResolvingAudioSource buildFromTrack(Track track, Uri artworkUrl) {
  final url = resourceToUrl(track.resource!);
  final List<Map<String, dynamic>> contributors =
      jsonDecode(track.contributors)['value'].cast<Map<String, dynamic>>();
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
  final String artist = contributorsByTypeMap['作曲者']?.join('/') ??
      contributorsByTypeMap['編曲者']?.join('/') ??
      contributorsByTypeMap['演奏者']?.join('/') ??
      contributorsByTypeMap.values.first?.join('/') ??
      '不明';
  return ResolvingAudioSource(
      uniqueId: '0',
      url: url,
      headersCreater: createHeader(url),
      tag: MediaItem(
          id: track.id.toString(),
          title: track.title,
          artist: artist,
          duration: Duration(seconds: track.duration),
          album: track.albumTitle,
          artUri: artworkUrl,
          genre: track.genre,
          extras: {"albumId": track.albumId}));
}

class PlayState with ChangeNotifier {
  bool _isPlaying = false;
  int? _currentTrackId;
  ProcessingState? _processingState;
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffling = false;
  bool _hasNextTrack = false;
  bool _hasPreviousTrack = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isPlaying => _isPlaying;
  int? get currentTrackId => _currentTrackId;
  ProcessingState? get processingState => _processingState;
  ConcatenatingAudioSource get playlist => _playlist;
  AudioPlayer get audioPlayer => _audioPlayer;
  LoopMode get loopMode => _loopMode;
  bool get isShuffling => _isShuffling;
  bool get hasNextTrack => _hasNextTrack;
  bool get hasPreviousTrack => _hasPreviousTrack;

  PlayState() {
    setListener(_audioPlayer
      ..setAudioSource(_playlist)
      ..setLoopMode(LoopMode.off));
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void setPlaying(bool isPlaying) {
    _isPlaying = isPlaying;
    notifyListeners();
  }

  Future<void> playIndexItem(int index) async {
    await audioPlayer.seek(Duration.zero, index: index);
    _currentTrackId = int.parse(
        ((_playlist.children[index] as ResolvingAudioSource).tag as MediaItem)
            .id);
    _audioPlayer.play();
  }

  Future<void> setTracksAsSource(List<Track> tracks) async {
    await playlist.clear();

    await _playlist.addAll(tracks.map((track) {
      return buildFromTrack(track, Uri.parse(track.artworkUrl));
    }).toList());
    setHasPreviousNextTrack();
    _audioPlayer.play();
  }

  Future<void> queueTracksAsSource(List<Track> tracks) async {
    await _playlist.addAll(tracks.map((track) {
      return buildFromTrack(track, Uri.parse(track.artworkUrl));
    }).toList());
    setHasPreviousNextTrack();
    notifyListeners();
  }

  Future<void> setShuffle(bool isShuffling) async {
    _isShuffling = isShuffling;
    await _audioPlayer.setShuffleModeEnabled(isShuffling);
    setHasPreviousNextTrack();
    notifyListeners();
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    _loopMode = loopMode;
    await _audioPlayer.setLoopMode(loopMode);
    setHasPreviousNextTrack();
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(int index) async {
    await _playlist.removeAt(index);
    setHasPreviousNextTrack();
    notifyListeners();
  }

  void setHasPreviousNextTrack() {
    _hasNextTrack = audioPlayer.nextIndex != null;
    _hasPreviousTrack = audioPlayer.previousIndex != null;
  }

  Future<void> playFirstTrack() async {
    await audioPlayer.seek(Duration.zero, index: 0);
    _audioPlayer.play();
  }

  void setListener(AudioPlayer audioPlayer) {
    audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      if (playlist.children.length <= index) return;
      final currentSource = playlist.children[index] as ResolvingAudioSource;
      final trackId = int.parse(currentSource.tag.id);
      setHasPreviousNextTrack();
      _currentTrackId = trackId;
      notifyListeners();
    });

    audioPlayer.playerStateStream.listen((event) {
      final processingState = event.processingState;
      final playing = event.playing;

      _processingState = processingState;
      _isPlaying = playing;
      if (audioPlayer.currentIndex != null) {
        final idx = audioPlayer.currentIndex!;
        if (idx >= playlist.children.length) return;
        final currentSource = playlist.children[idx] as ResolvingAudioSource;
        if (currentSource.tag.id != currentTrackId.toString()) {
          _currentTrackId = int.parse(currentSource.tag.id);
        }
      }
      notifyListeners();
    });
  }
}
