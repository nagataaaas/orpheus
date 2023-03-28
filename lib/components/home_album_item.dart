import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeAlbumItem extends StatelessWidget {
  final Uri artworkUrl;
  final String id;
  final bool isPlayable;
  final String resource;
  final DateTime siteReleaseDate;
  final String title;
  final String originalTitle;

  final Map<String, dynamic> json;

  const HomeAlbumItem({
    super.key,
    required this.artworkUrl,
    required this.id,
    required this.isPlayable,
    required this.resource,
    required this.siteReleaseDate,
    required this.title,
    required this.originalTitle,
    required this.json,
  });

  static HomeAlbumItem fromJson(Map<String, dynamic> json) {
    return HomeAlbumItem(
        artworkUrl: Uri.parse(json['artwork']['resource']),
        id: json['id'],
        isPlayable: json['isplayable'],
        resource: json['resource'],
        siteReleaseDate:
            DateFormat("yyyy/MM/dd").parse(json['sitereleasedate']),
        title: json['title'],
        originalTitle: json['titleorig'],
        json: json);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(children: [
              Image.network(
                artworkUrl.toString(),
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/no-image.jpg',
                    width: 100,
                    height: 100,
                  );
                },
                width: 100,
                height: 100,
              ),
              Expanded(
                  child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                height: 100,
                child: Stack(
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 14, height: 1.2)),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                            DateFormat("yyyy/MM/dd").format(siteReleaseDate!),
                            style: const TextStyle(fontSize: 15))),
                  ],
                ),
              )),
            ])),
        const Divider()
      ],
    );
  }
}
