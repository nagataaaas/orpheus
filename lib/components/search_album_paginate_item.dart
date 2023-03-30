import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/styles.dart';

class SearchAlbumPaginateItem extends StatelessWidget {
  final Uri artworkUrl;
  final String id;
  final bool isPlayable;
  final String resource;
  final String title;
  final String description;
  final String labelDescription;

  final Map<String, dynamic> json;

  const SearchAlbumPaginateItem({
    super.key,
    required this.artworkUrl,
    required this.id,
    required this.isPlayable,
    required this.resource,
    required this.title,
    required this.json,
    required this.description,
    required this.labelDescription,
  });

  static SearchAlbumPaginateItem fromJson(Map<String, dynamic> json) {
    return SearchAlbumPaginateItem(
        artworkUrl: Uri.parse(json['artwork']['resource']),
        id: json['id'],
        isPlayable: json['isplayable'],
        resource: json['resource'],
        title: json['title'],
        description: json['description'],
        labelDescription: json['label']['description'],
        json: json);
  }

  @override
  Widget build(BuildContext context) {
    final image = NetworkImage(artworkUrl.toString());
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: CommonColors.primaryDarkTextColor,
              elevation: 0),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                  builder: (context) => CommonAlbumScreen(
                        albumId: resource.split('/').last,
                        albumTitle: title,
                        image: image,
                      )),
            );
          },
          child: Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Row(children: [
                FadeInImage(
                    image: image,
                    placeholder: const AssetImage('assets/no-image.jpg'),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/no-image.jpg',
                          width: 100, height: 100, fit: BoxFit.cover);
                    },
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover),
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
                          child: Text(labelDescription,
                              style: const TextStyle(fontSize: 15))),
                    ],
                  ),
                )),
              ])),
        ),
        const Divider()
      ],
    );
  }
}
