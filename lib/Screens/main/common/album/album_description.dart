import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orpheus_client/components/skelton_text.dart';

class AlbumDescription extends StatelessWidget {
  final String? title;
  final String? label;
  final Function() showDescription;
  final Function() addToPlaylist;
  final Function() addToQueue;
  final Function() playShuffle;

  const AlbumDescription({
    Key? key,
    required this.title,
    required this.label,
    required this.showDescription,
    required this.addToPlaylist,
    required this.addToQueue,
    required this.playShuffle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black87,
              ],
              stops: [
                0.00022,
                1.0,
              ]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: showDescription,
                child: Column(
                  children: [
                    title == null
                        ? SkeletonText(height: 28, width: size.width * 0.8)
                        : Text(title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        label == null
                            ? SkeletonText(height: 28, width: size.width * 0.8)
                            : Text(
                                "Provider: ${(jsonDecode(label!)?['description'] ?? "Unknown Label")}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: addToPlaylist,
                      tooltip: "プレイリストに追加",
                      icon: const Icon(
                        Icons.playlist_add_rounded,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: addToQueue,
                      tooltip: "キューに追加",
                      icon: const Icon(
                        Icons.queue_music_rounded,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: playShuffle,
                      tooltip: "シャッフル再生",
                      icon: const Icon(
                        Icons.shuffle_rounded,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: showDescription,
                      tooltip: "詳細を表示",
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
