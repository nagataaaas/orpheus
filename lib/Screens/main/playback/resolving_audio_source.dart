import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart'
    show AudioSourceMessage, ProgressiveAudioSourceMessage;

class ResolvingAudioSource extends StreamAudioSource {
  final String uniqueId;
  final Uri url;
  final Future<Map<String, String>> Function() headersCreater;
  late Map<String, String> headers;

  HttpClient? _httpClient;

  HttpClient get httpClient => _httpClient ?? (_httpClient = HttpClient());

  ResolvingAudioSource(
      {required this.uniqueId,
      required this.url,
      required this.headersCreater,
      dynamic tag})
      : super(tag: tag);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final request = await httpClient.getUrl(url);

    headers = await headersCreater();
    for (var entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
    if (start != null || end != null) {
      request.headers
          .set(HttpHeaders.rangeHeader, 'bytes=${start ?? ""}-${end ?? ""}');
    }
    final response = await request.close();
    final acceptRangesHeader =
        response.headers.value(HttpHeaders.acceptRangesHeader);
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    int? offset;
    if (contentRange != null) {
      int offsetEnd = contentRange.indexOf('-');
      if (offsetEnd >= 6) {
        offset = int.tryParse(contentRange.substring(6, offsetEnd));
      }
    }
    final contentLength =
        response.headers.value(HttpHeaders.contentLengthHeader);
    final contentType = response.headers.value(HttpHeaders.contentTypeHeader);
    return StreamAudioResponse(
        rangeRequestsSupported:
            acceptRangesHeader != null && acceptRangesHeader != 'none',
        sourceLength: null,
        contentLength:
            contentLength == null ? null : int.tryParse(contentLength),
        offset: offset,
        stream: response.asBroadcastStream(),
        contentType: contentType ?? "");
  }

  @override
  AudioSourceMessage _toMessage() {
    return ProgressiveAudioSourceMessage(
        id: uniqueId, uri: url.toString(), headers: headers, tag: tag);
  }
}
